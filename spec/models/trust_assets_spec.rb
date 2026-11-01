require 'rails_helper'

RSpec.describe TrustAsset, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  before(:all) do
    MeiliSearch::Rails.configuration[:active] = false rescue nil
  end

  before do
    allow_any_instance_of(TrustAsset).to receive(:index_to_meilisearch).and_return(true)
    allow_any_instance_of(TrustAsset).to receive(:index!).and_return(true)
    allow_missing_to_receive(MeiliSearch::Rails) if respond_to?(:allow_missing_to_receive)
  end


  describe 'Associations' do
    it { should belong_to(:workspace) }
    it { should belong_to(:environment) }
  end

  describe 'Validations' do
    subject { create(:trust_asset) }

    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:workspace_id, :environment_id) }
    it { should validate_presence_of(:format) }

    context 'Format de nom' do
      it { should allow_value('valid-asset_name.01').for(:name) }
      it { should_not allow_value('invalid@name!').for(:name).with_message('only allows numbers, dots, dashes, and underscores') }
    end

    context 'Validation conditionnelle de :issuer' do
      it 'requiert issuer si le format n’est pas tls_certificate ni domain' do
        asset = TrustAsset.new(format: :token)
        asset.valid?
        expect(asset.errors[:issuer]).to include("can't be blank")
      end
    end

    context 'Validation conditionnelle de :consumer' do
      it 'requiert consumer si format != domain' do
        asset = TrustAsset.new(format: :token)
        asset.valid?
        expect(asset.errors[:consumer]).to include("can't be blank")
      end

      it 'ne requiert pas consumer si format == domain' do
        asset = TrustAsset.new(format: :domain)
        asset.valid?
        expect(asset.errors[:consumer]).to be_empty
      end
    end

    context 'Validation de la date d’expiration' do
      it 'est invalide si la date d’expiration est dans le passé' do
        asset = TrustAsset.new(expires_at: 1.day.ago)
        asset.valid?
        expect(asset.errors[:expires_at]).to include("doit être une date future")
      end

      it 'est valide si la date d’expiration est dans le futur' do
        asset = TrustAsset.new(expires_at: 1.day.from_now)
        asset.valid?
        expect(asset.errors[:expires_at]).to_not include("doit être une date future")
      end
    end
  end

  describe 'Enums' do
    it { should define_enum_for(:format).with_values(tls_certificate: 0, token: 1, domain: 2) }
  end

  describe 'Scopes' do
    describe '.active' do
      it 'retourne les assets non expirés ou sans date d’expiration' do
        travel_to Time.zone.parse('2026-11-01 12:00:00') do
          active_asset = TrustAsset.create!(name: 'active', format: :token, issuer: 'test', consumer: 'test', expires_at: 1.hour.from_now, workspace: create(:workspace), environment: create(:environment))
          nil_expiry_asset = TrustAsset.create!(name: 'nil-expiry', format: :domain, workspace: create(:workspace), environment: create(:environment))
          
          expired_asset = TrustAsset.new(name: 'expired', format: :token, issuer: 'test', consumer: 'test', expires_at: 1.hour.ago, workspace: create(:workspace), environment: create(:environment))
          expired_asset.save!(validate: false)

          expect(TrustAsset.active).to include(active_asset, nil_expiry_asset)
          expect(TrustAsset.active).not_to include(expired_asset)
        end
      end
    end
  end

  describe '#expiry_level' do
    let(:asset) { TrustAsset.new(reminder_days: 7) }

    it 'retourne -1 si expires_at est nil' do
      asset.expires_at = nil
      expect(asset.expiry_level).to eq(-1)
    end

    it 'retourne 2 si l’asset est expiré' do
      asset.expires_at = 1.day.ago
      expect(asset.expiry_level).to eq(2)
    end

    it 'retourne 1 si l’asset entre dans la période d’avertissement (reminder_days)' do
      asset.expires_at = 5.days.from_now
      expect(asset.expiry_level).to eq(1)
    end

    it 'retourne 0 s’il n’y a aucun danger' do
      asset.expires_at = 15.days.from_now
      expect(asset.expiry_level).to eq(0)
    end
  end

  describe '#update_expiry' do
    let(:workspace) { create(:workspace) }
    let(:environment) { create(:environment) }
    
    context 'quand format est tls_certificate' do
      let(:asset) { TrustAsset.new(name: 'example.com', format: :tls_certificate, workspace: workspace, environment: environment) }

      it 'met à jour les détails de l’asset depuis le certificat SSL' do
        allow(asset).to receive(:ssl_certificate_details).and_return({
          expiry_date: Time.zone.parse('2027-01-01'),
          issuer_name: 'Let\'s Encrypt'
        })

        asset.update_expiry
        expect(asset.expires_at).to eq(Time.zone.parse('2027-01-01'))
        expect(asset.issuer).to eq('Let\'s Encrypt')
      end

      it 'gère le cas où le certificat est invalide ou inaccessible' do
        allow(asset).to receive(:ssl_certificate_details).and_return(nil)
        asset.update_expiry
        expect(asset.issuer).to eq("Invalid domain name, cannot get the issuer")
      end
    end

    context 'quand format est domain' do
      let(:asset) { TrustAsset.new(name: 'example.com', format: :domain, workspace: workspace, environment: environment) }

      it 'met à jour la date de fin via les données Whois' do
        allow(asset).to receive(:get_domain_expiration).and_return({
          expires_at: Time.zone.parse('2028-05-01'),
          registrar: 'Gandi'
        })

        asset.update_expiry
        expect(asset.expires_at).to eq(Time.zone.parse('2028-05-01'))
        expect(asset.issuer).to eq('Gandi')
      end
    end
  end

  describe '#ssl_certificate_details' do
    let(:asset) { TrustAsset.new(name: 'example.com') }

    it 'parse correctement le certificat lors d’une connexion TCP/SSL réussie' do
      double_http = instance_double(Net::HTTP)
      allow(Net::HTTP).to receive(:new).and_return(double_http)
      allow(double_http).to receive(:use_ssl=)
      allow(double_http).to receive(:verify_mode=)
      allow(double_http).to receive(:open_timeout=)
      allow(double_http).to receive(:read_timeout=)

      cert_mock = double('OpenSSL::X509::Certificate', not_after: Time.zone.parse('2027-11-01'))
      issuer_mock = double('Issuer', to_a: [['O', 'DigiCert Inc']], to_s: 'O=DigiCert Inc')
      allow(cert_mock).to receive(:issuer).and_return(issuer_mock)

      allow(double_http).to receive(:start).and_yield(double('Connection', peer_cert: cert_mock))

      details = asset.ssl_certificate_details
      expect(details[:issuer_name]).to eq('DigiCert Inc')
      expect(details[:expiry_date]).to eq(Time.zone.parse('2027-11-01'))
    end

    it 'intercepte les erreurs et retourne nil en cas de problème réseau' do
      allow(Net::HTTP).to receive(:new).and_raise(Timeout::Error.new("Timeout"))
      expect(asset.ssl_certificate_details).to be_nil
    end
  end

  describe '#get_domain_expiration' do
    let(:asset) { TrustAsset.new(name: 'google.com') }

    it 'extrait les informations Whois via le parser natif' do
      whois_client = instance_double(Whois::Client)
      whois_record = double('Whois::Record', content: 'Raw content')
      whois_parser = double('Whois::Parser', expires_on: Time.zone.parse('2029-01-01'), registrar: double(name: 'MarkMonitor'))
      
      allow(Whois::Client).to receive(:new).and_return(whois_client)
      allow(whois_client).to receive(:lookup).with('google.com').and_return(whois_record)
      allow(whois_record).to receive(:parser).and_return(whois_parser)

      result = asset.get_domain_expiration
      expect(result[:expires_at]).to eq(Time.zone.parse('2029-01-01'))
      expect(result[:registrar]).to eq('MarkMonitor')
    end
  end

  describe '.as_json_api' do
    it 'formate correctement la liste d’assets selon la structure spécifiée' do
      env = double('Environment', name: 'Production')
      asset = double('TrustAsset', name: 'api.io', issuer: 'Let\'s', format: 'token', expires_at: nil, consumer: 'App', description: 'Desc', reminder_days: 5, environment: env)
      
      json = TrustAsset.as_json_api([asset])
      expect(json.first[:name]).to eq('api.io')
      expect(json.first[:environment]).to eq('Production')
    end
  end

  describe '.cost' do
    it 'calcule le coût total basé sur le modèle Cost' do
      allow(TrustAsset).to receive(:count).and_return(5)
      allow(Cost).to receive(:find).with('TrustAsset').and_return(double(credits: 10))

      expect(TrustAsset.cost).to eq(50)
    end
  end
end
