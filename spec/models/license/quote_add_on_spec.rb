require 'rails_helper'

RSpec.describe License::QuoteAddOn, type: :model do
  describe 'Associations' do
    it { should belong_to(:add_on) }
    it { should belong_to(:quote_instance) }
  end

  describe 'Validations' do
    it 'valide que le montant est positif ou nul' do
      should validate_numericality_of(:amount)
        .is_greater_than_or_equal_to(0)
        .allow_nil
    end
  end
end