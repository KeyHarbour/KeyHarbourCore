require 'rails_helper'
require 'tempfile'

RSpec.describe License::Licensee, type: :model do
  let(:instance) { create(:license_instance) }

  describe 'associations and validations' do
    it { should belong_to(:instance).class_name('License::Instance') }
    it { should validate_presence_of(:uuid) }

    it 'includes Archivable module' do
      expect(described_class.included_modules).to include(Archivable)
    end
  end

  describe '#import_file=' do
    let!(:existing_licensee) do
      create(:license_licensee, instance: instance, uuid: 'alice@example.com', revision: 'old-rev')
    end
    let!(:stale_licensee) do
      create(:license_licensee, instance: instance, uuid: 'removed@example.com', revision: 'old-rev')
    end

    let(:csv_content) do
      <<~CSV
        name,last_access
        alice@example.com,2026-10-01 10:00:00
        bob@example.com,
      CSV
    end

    let(:temp_csv) do
      file = Tempfile.new(['licensees', '.csv'])
      file.write(csv_content)
      file.rewind
      Rack::Test::UploadedFile.new(file.path, 'text/csv', original_filename: 'licensees.csv')
    end

    after do
      temp_csv.close
      temp_csv.unlink
    end

    it 'creates new licensees, updates existing ones, and destroys stale licensees' do
      licensee = described_class.new(instance: instance)
      licensee.import_file = temp_csv

      expect(instance.licensees.count).to eq(2)

      # Existing licensee is updated (last_access is a Date column)
      existing_licensee.reload
      expect(existing_licensee.last_access).to eq(Date.parse('2026-10-01'))
      expect(existing_licensee.revision).not_to eq('old-rev')

      # New licensee is created
      bob = instance.licensees.find_by(uuid: 'bob@example.com')
      expect(bob).to be_present
      expect(bob.last_access).to be_nil
      expect(bob.revision).to eq(existing_licensee.revision)

      # Stale licensee not in CSV is destroyed
      expect(described_class.exists?(stale_licensee.id)).to be(false)
    end
  end

  describe '.calculate_total_costs' do
    let(:tree_data) do
      [
        { id: 1, parent_id: nil, name: 'CEO', cost: 100.0 },
        { id: 2, parent_id: 1, name: 'Manager', cost: 50.0 },
        { id: 3, parent_id: 2, name: 'Developer', cost: 25.5 },
        { id: 4, parent_id: '', name: 'Independent', cost: 10.0 }
      ]
    end

    it 'recursively sums costs from children to root nodes and formats them as currency' do
      result = described_class.calculate_total_costs(tree_data)

      ceo = result.find { |n| n[:id] == 1 }
      manager = result.find { |n| n[:id] == 2 }
      dev = result.find { |n| n[:id] == 3 }
      independent = result.find { |n| n[:id] == 4 }

      expect(dev[:total_cost]).to eq('$25.50')
      expect(manager[:total_cost]).to eq('$75.50')
      expect(ceo[:total_cost]).to eq('$175.50')
      expect(independent[:total_cost]).to eq('$10.00')
    end
  end

  describe '.tree and .add_member' do
    let(:account) { create(:account) }
    let(:manager_member) do
      account.app_team_members.create!(uuid: 'manager@example.com', role: 'VP', manager: nil)
    end
    let(:subordinate_member) do
      account.app_team_members.create!(uuid: 'dev@example.com', role: 'Engineer', manager: manager_member)
    end

    before do
      stub_const('Current', double('Current', account: account))
      allow(instance).to receive(:cost).and_return(50.0)
      allow_any_instance_of(String).to receive(:red) { |str| str }
    end

    it 'builds the hierarchy including non-licensed managers with 0 cost and creates missing team members' do
      create(:license_licensee, instance: instance, uuid: subordinate_member.uuid)
      create(:license_licensee, instance: instance, uuid: 'new_user@example.com')

      tree = described_class.tree(instance)

      # Root node
      expect(tree).to include({ id: 0, name: 'Org', cost: 0 })

      # Licensed subordinate
      sub_node = tree.find { |n| n[:name] == 'dev@example.com' }
      expect(sub_node).to include(
        id: subordinate_member.id,
        parent_id: manager_member.id,
        manager_name: 'manager@example.com',
        role: 'Engineer',
        manager_role: 'VP',
        cost: 50.0
      )

      # Non-licensed manager added recursively with 0 cost
      mgr_node = tree.find { |n| n[:name] == 'manager@example.com' }
      expect(mgr_node).to include(
        id: manager_member.id,
        parent_id: 0,
        manager_name: nil,
        role: 'VP',
        manager_role: nil,
        cost: 0
      )

      # Automatically created team member for unknown licensee
      new_member = account.app_team_members.find_by(uuid: 'new_user@example.com')
      expect(new_member).to be_present
      new_node = tree.find { |n| n[:name] == 'new_user@example.com' }
      expect(new_node).to include(
        id: new_member.id,
        parent_id: 0,
        cost: 50.0
      )
    end
  end

  describe '.cost' do
    let(:other_instance) { create(:license_instance) }
    let(:cost_record) { double('Cost', credits: 15) }

    before do
      allow(Cost).to receive(:find).with('License').and_return(cost_record)
    end

    it 'multiplies unique licensee UUIDs by the License credit cost' do
      create(:license_licensee, instance: instance, uuid: 'duplicate@example.com')
      create(:license_licensee, instance: other_instance, uuid: 'duplicate@example.com')
      create(:license_licensee, instance: instance, uuid: 'unique@example.com')

      scope = described_class.where(uuid: ['duplicate@example.com', 'unique@example.com'])
      expect(scope.cost).to eq(30) # 2 unique UUIDs * 15 credits
    end
  end
end
