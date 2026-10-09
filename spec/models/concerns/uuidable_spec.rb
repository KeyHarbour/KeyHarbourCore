# spec/models/concerns/uuidable_spec.rb
require 'rails_helper'


RSpec.describe Uuidable, type: :model do
  before(:all) do
    # 1. Création de la table temporaire
    ActiveRecord::Base.connection.create_table :test_uuidables, force: true do |t|
      t.string :uuid
      t.string :name
      t.timestamps
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :test_uuidables, if_exists: true
  end

  # 2. Utilisation d'une classe dynamique assignée à une variable locale (évite le NameError)
  # SimpleCov suit parfaitement l'exécution via les méthodes instanciées ici
  let(:test_model) do
    Class.new(ActiveRecord::Base) do
      self.table_name = 'test_uuidables'
      include Uuidable
    end
  end

  describe 'Callbacks (#assign_uuid)' do
    it 'génère et assigne automatiquement un UUID unique avant la création' do
      record = test_model.new(name: 'Test')
      expect(record.uuid).to be_nil

      record.save!
      expect(record.uuid).to be_present
      expect(record.uuid).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}\z/i)
    end

    it 'utilise SecureRandom.uuid pour générer la valeur' do
      allow(SecureRandom).to receive(:uuid).and_return('mocked-uuid-1234')
      
      record = test_model.create!(name: 'Test')
      expect(record.uuid).to eq('mocked-uuid-1234')
    end

    it 'ne modifie pas l_uuid lors de la mise à jour (update)' do
      record = test_model.create!(name: 'Initial')
      initial_uuid = record.uuid

      record.update!(name: 'Modifié')
      expect(record.reload.uuid).to eq(initial_uuid)
    end
  end
end
