require 'rails_helper'

RSpec.describe License::Quote, type: :model do
  describe 'Associations' do
    it { should belong_to(:application) }
    it { should belong_to(:provider) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:uuid) }
    
    context 'Uniq' do
      # On utilise une factory persistée pour que les clés étrangères existent en BDD
      subject { create(:license_quote) }
      it { should validate_uniqueness_of(:uuid).case_insensitive }
    end
  end
end
