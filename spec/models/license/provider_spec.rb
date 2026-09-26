require 'rails_helper'

RSpec.describe License::Provider, type: :model do
  describe 'Associations' do
    it { should belong_to(:account) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:uuid) }
    
    context 'Unicité' do
      # On utilise la factory pour créer un enregistrement valide en BDD au préalable
      subject { create(:license_provider) }
      
      it { should validate_uniqueness_of(:uuid).case_insensitive }
    end
  end
end
