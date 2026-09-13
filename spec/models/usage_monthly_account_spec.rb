require 'rails_helper'

RSpec.describe UsageMonthlyAccount, type: :model do
  subject(:record) { build(:usage_monthly_account) }

  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:month) }

    it "rejects duplicate month for the same account" do
      existing = create(:usage_monthly_account)
      duplicate = build(:usage_monthly_account, account: existing.account, month: existing.month)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:month]).to be_present
    end

    it "allows same month for different accounts" do
      existing = create(:usage_monthly_account)
      other = build(:usage_monthly_account, month: existing.month)
      expect(other).to be_valid
    end

    it "allows same account with different months" do
      existing = create(:usage_monthly_account)
      other = build(:usage_monthly_account, account: existing.account, month: 1.month.ago.beginning_of_month)
      expect(other).to be_valid
    end
  end
end
