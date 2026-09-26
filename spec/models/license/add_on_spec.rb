require 'rails_helper'

RSpec.describe License::AddOn, type: :model do
  describe "associations" do
    it { should belong_to(:instance) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:uuid) }
    
    it 'valide que le coût unitaire est positif ou nul' do
      should validate_numericality_of(:unit_cost)
        .is_greater_than_or_equal_to(0)
        .allow_nil
    end
  end

  describe 'Valeurs par défaut et Initialisation' do
    it 'est actif par défaut à la création' do
      add_on = License::AddOn.new
      expect(add_on.active).to be true
    end

    it 'gère la précision du unit_cost à 4 décimales' do
      add_on = License::AddOn.new(unit_cost: 12.34567)
      # Le changement de précision se fait au moment du save ou du cast de l'attribut
      expect(add_on.unit_cost).to eq(12.3457) # Arrondi automatique par la base de données
    end
  end
end
