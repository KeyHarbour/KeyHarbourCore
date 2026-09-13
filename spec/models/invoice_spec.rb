require 'rails_helper'

RSpec.describe Invoice, type: :model do
  subject(:invoice) { build(:invoice) }

  describe "associations" do
    it { is_expected.to belong_to(:subscription) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:stripe_invoice_id) }
    it { is_expected.to validate_uniqueness_of(:stripe_invoice_id) }

    it "rejects duplicate stripe_invoice_id" do
      existing = create(:invoice)
      duplicate = build(:invoice, stripe_invoice_id: existing.stripe_invoice_id)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:stripe_invoice_id]).to be_present
    end
  end

  describe "#account" do
    it "delegates to subscription" do
      expect(invoice.account).to eq(invoice.subscription.account)
    end
  end

  describe "tax calculations" do
    before { invoice.amount = 100.00 }

    it "#tps returns 5%" do
      expect(invoice.tps).to eq(5.00)
    end

    it "#tvq returns 9.975%" do
      expect(invoice.tvq).to eq(9.98)
    end

    it "#total returns amount + tps + tvq" do
      expect(invoice.total).to eq(114.98)
    end
  end
end
