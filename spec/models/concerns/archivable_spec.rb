# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Archivable, type: :model do
  # 1. Création d'une table et d'un modèle temporaires pour isoler le test du Concern
  before(:all) do
    ActiveRecord::Base.connection.create_table :dummy_archivables, force: true do |t|
      t.integer :status, default: 0
      t.string :name
      t.datetime :archived_at
      t.timestamps
    end
  end

  after(:all) do
    ActiveRecord::Base.connection.drop_table :dummy_archivables, if_exists: true
  end

  # Définition de la classe temporaire qui inclut le Concern
  class DummyArchivable < ActiveRecord::Base
    include Archivable
  end

  # Nettoyage de la base de données entre chaque test si vous n'utilisez pas database_cleaner
  after(:each) do
    DummyArchivable.delete_all
  end

  describe 'enums et scopes' do
    # Nécessite la gem shoulda-matchers. 
    # Si vous ne l'avez pas, vous pouvez supprimer cette ligne, les tests de scopes valident déjà l'enum indirectement.
    it { expect(DummyArchivable.new).to define_enum_for(:status).with_values(active: 0, disabled: 1, archived: 2) }

    let!(:active_item)   { DummyArchivable.create!(status: :active) }
    let!(:disabled_item) { DummyArchivable.create!(status: :disabled) }
    let!(:archived_item) { DummyArchivable.create!(status: :archived) }

    it 'filtre correctement avec le scope .active' do
      expect(DummyArchivable.active).to include(active_item)
      expect(DummyArchivable.active).not_to include(disabled_item, archived_item)
    end

    it 'filtre correctement avec le scope .not_archived' do
      expect(DummyArchivable.not_archived).to include(active_item, disabled_item)
      expect(DummyArchivable.not_archived).not_to include(archived_item)
    end

    it 'filtre correctement avec le scope .disabled' do
      expect(DummyArchivable.disabled).to include(disabled_item)
      expect(DummyArchivable.disabled).not_to include(active_item, archived_item)
    end

    it 'filtre correctement avec le scope .archived' do
      expect(DummyArchivable.archived).to include(archived_item)
      expect(DummyArchivable.archived).not_to include(active_item, disabled_item)
    end
  end

  describe 'méthodes d\'instance' do
    describe '#active?' do
      it { expect(DummyArchivable.new(status: :active)).to be_active }
      it { expect(DummyArchivable.new(status: :archived)).not_to be_active }
    end

    describe '#disabled?' do
      it { expect(DummyArchivable.new(status: :disabled)).to be_disabled }
      it { expect(DummyArchivable.new(status: :active)).not_to be_disabled }
    end

    describe '#archived?' do
      it { expect(DummyArchivable.new(status: :archived)).to be_archived }
      it { expect(DummyArchivable.new(status: :active)).not_to be_archived }
    end
  end

  describe 'callbacks (prevent_modification_if_previously_archived)' do
    context 'lorsque l\'item n\'était PAS archivé' do
      let(:item) { DummyArchivable.create!(status: :active, name: 'Ancien nom') }

      it 'permet de modifier n\'importe quel attribut de l\'objet' do
        item.name = 'Nouveau nom'
        expect(item.save).to be_truthy
        expect(item.reload.name).to eq('Nouveau nom')
      end
    end

    context 'lorsque l\'item ÉTAIT archivé' do
      let!(:item) { DummyArchivable.create!(status: :archived, name: 'Item Archivé') }

      it 'permet de changer le status (ex: réactiver)' do
        item.status = :active
        expect(item.save).to be_truthy
        expect(item.reload.status).to eq('active')
      end

      it 'permet de modifier les colonnes autorisées (archived_at, updated_at)' do
        item.archived_at = Time.current
        expect(item.save).to be_truthy
      end

      it 'bloque la modification de tout autre attribut non autorisé' do
        item.name = 'Tentative de changement'
        
        expect(item.save).to be_falsey
        expect(item.errors[:base]).to include(
          I18n.t('models.concerns.archivable.archived_item_error', changes: 'name')
        )
      end
    end
  end
end
