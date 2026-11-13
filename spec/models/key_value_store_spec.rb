require 'rails_helper'

RSpec.describe KeyValueStore, type: :model do
  let(:workspace) { create(:workspace) }
  let(:environment) { create(:environment, name: 'production') }

  let(:dummy_file) do
    Rack::Test::UploadedFile.new(
      StringIO.new("secret file content"),
      "text/plain",
      original_filename: "secret.txt"
    )
  end

  before do
    # Configure temporary ActiveRecord Encryption keys for the test environment
    ActiveRecord::Encryption.configure(
      primary_key: "test_primary_key_32_characters_!",
      deterministic_key: "test_deterministic_key_32_chars!",
      key_derivation_salt: "test_key_derivation_salt_32_char"
    )

    # Stub MeiliSearch indexing during unit tests
    allow_any_instance_of(KeyValueStore).to receive(:index_to_meilisearch)
  end

  describe 'associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:environment) }
    it { should have_one_attached(:value_file) }
  end

  describe 'validations' do
    subject { build(:key_value_store, workspace: workspace, environment: environment, key: 'API_KEY', value: '12345') }

    it { should validate_presence_of(:key) }
    it { should validate_uniqueness_of(:key).scoped_to(:workspace_id, :environment_id) }

    context 'key format (VALID_FORMAT_REGEX)' do
      it 'allows letters, numbers, dots, dashes, and underscores' do
        valid_keys = %w[API_KEY my-key.123 secret_v2.0]
        valid_keys.each do |valid_key|
          subject.key = valid_key
          expect(subject).to be_valid
        end
      end

      it 'rejects spaces and special characters' do
        invalid_keys = ['api key', 'secret@key', 'accented_é', 'key/name']
        invalid_keys.each do |invalid_key|
          subject.key = invalid_key
          expect(subject).not_to be_valid
          expect(subject.errors[:key]).to include("only allows numbers, dots, dashes, and underscores")
        end
      end
    end

    context 'custom validation at_least_one_value_present' do
      it 'is invalid when neither value nor value_file is present' do
        kv = build(:key_value_store, workspace: workspace, environment: environment, value: nil, value_file: nil)
        expect(kv).not_to be_valid
        expect(kv.errors[:base]).to include("value or value_file should not be empty")
      end

      it 'is valid when only value is present' do
        kv = build(:key_value_store, workspace: workspace, environment: environment, value: 'secret', value_file: nil)
        expect(kv).to be_valid
      end

      it 'is valid when only value_file is present' do
        kv = build(:key_value_store, workspace: workspace, environment: environment, value: nil, value_file: dummy_file)
        expect(kv).to be_valid
      end
    end
  end

  describe 'mutual exclusion between value and value_file' do
    it 'clears value when value_file is assigned' do
      kv = build(:key_value_store, workspace: workspace, environment: environment, value: 'initial_secret')
      kv.value_file = dummy_file

      expect(kv.value).to be_nil
      expect(kv.value_file).to be_attached
      expect(kv).to be_valid
    end

    it 'clears value_file when value is assigned' do
      kv = build(:key_value_store, workspace: workspace, environment: environment, value: nil, value_file: dummy_file)
      kv.value = 'new_secret'

      expect(kv.value).to eq('new_secret')
      expect(kv.value_file).not_to be_attached
      expect(kv).to be_valid
    end
  end

  describe 'scopes' do
    describe '.active' do
      let!(:active_no_expiry) { create(:key_value_store, workspace: workspace, environment: environment, key: 'K1', value: 'v', expires_at: nil) }
      let!(:active_future)    { create(:key_value_store, workspace: workspace, environment: environment, key: 'K2', value: 'v', expires_at: 1.day.from_now) }
      let!(:expired)          { create(:key_value_store, workspace: workspace, environment: environment, key: 'K3', value: 'v', expires_at: 1.day.ago) }

      it 'returns only non-expired records or records without an expiration date' do
        active_records = KeyValueStore.active
        expect(active_records).to include(active_no_expiry, active_future)
        expect(active_records).not_to include(expired)
      end
    end

    describe '.for_environment' do
      let(:other_env) { create(:environment, name: 'staging') }
      let!(:prod_kv)  { create(:key_value_store, workspace: workspace, environment: environment, key: 'PROD_KEY', value: 'v') }
      let!(:stage_kv) { create(:key_value_store, workspace: workspace, environment: other_env, key: 'STAGE_KEY', value: 'v') }

      it 'filters records by environment' do
        expect(KeyValueStore.for_environment(environment)).to contain_exactly(prod_kv)
      end
    end
  end

  describe '.as_json_api (Security and value masking)' do
    let(:secret_value) { 'SUPER_SECRET_TOKEN_987654' }

    context 'when key is public and reusable (private: false, one_time_only: false)' do
      let!(:public_kv) do
        create(:key_value_store,
               workspace: workspace,
               environment: environment,
               key: 'PUBLIC_URL',
               value: secret_value,
               private: false,
               one_time_only: false)
      end

      it 'returns the value in plain text' do
        result = KeyValueStore.as_json_api([public_kv]).first

        expect(result[:key]).to eq('PUBLIC_URL')
        expect(result[:value]).to eq(secret_value)
        expect(result[:private]).to be(false)
        expect(result[:environment]).to eq('production')
      end
    end

    context 'when private is enabled (private: true, one_time_only: false)' do
      let!(:private_kv) do
        create(:key_value_store,
               workspace: workspace,
               environment: environment,
               key: 'DB_PASSWORD',
               value: secret_value,
               private: true,
               one_time_only: false)
      end

      it 'masks the value with *** and never leaks the secret' do
        result = KeyValueStore.as_json_api([private_kv]).first

        expect(result[:value]).to eq('***')
        expect(result[:value]).not_to eq(secret_value)
        expect(result.to_json).not_to include(secret_value)
      end
    end

    context 'when one_time_only is enabled (private: false, one_time_only: true)' do
      let!(:oto_kv) do
        create(:key_value_store,
               workspace: workspace,
               environment: environment,
               key: 'ONE_TIME_TOKEN',
               value: secret_value,
               private: false,
               one_time_only: true)
      end

      it 'masks the value with *** and never leaks the secret' do
        result = KeyValueStore.as_json_api([oto_kv]).first

        expect(result[:value]).to eq('***')
        expect(result[:value]).not_to eq(secret_value)
        expect(result.to_json).not_to include(secret_value)
      end
    end

    context 'when both private and one_time_only are enabled' do
      let!(:strict_kv) do
        create(:key_value_store,
               workspace: workspace,
               environment: environment,
               key: 'ULTRA_SECRET',
               value: secret_value,
               private: true,
               one_time_only: true)
      end

      it 'masks the value with *** and never leaks the secret' do
        result = KeyValueStore.as_json_api([strict_kv]).first

        expect(result[:value]).to eq('***')
        expect(result.to_json).not_to include(secret_value)
      end
    end
  end

  describe '#index_to_meilisearch' do
    it 'indexes the record and waits for the MeiliSearch task to complete' do
      allow_any_instance_of(KeyValueStore).to receive(:index_to_meilisearch).and_call_original

      kv = build(:key_value_store, workspace: workspace, environment: environment, value: 'test')
      mock_task = [double(metadata: { "taskUid" => 42 })]
      mock_client = double('MeiliSearchClient')

      expect(kv).to receive(:index!).and_return(mock_task)
      allow(MeiliSearch::Rails).to receive(:client).and_return(mock_client)
      expect(mock_client).to receive(:wait_for_task).with(42)

      kv.save!
    end
  end
end
