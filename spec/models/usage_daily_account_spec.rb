require 'rails_helper'

RSpec.describe UsageDailyAccount, type: :model do
  subject(:record) { build(:usage_daily_account) }

  describe "associations" do
    it { is_expected.to belong_to(:account) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }

    it "is invalid without a service_name" do
      record.service_name = nil
      expect(record).not_to be_valid
    end

    it "rejects duplicate day/account/service_name" do
      existing = create(:usage_daily_account)
      duplicate = build(:usage_daily_account, account: existing.account, day: existing.day, service_name: existing.service_name)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:day]).to be_present
    end

    it "allows same day with different service_name" do
      existing = create(:usage_daily_account)
      other = build(:usage_daily_account, account: existing.account, day: existing.day, service_name: "Statefile")
      expect(other).to be_valid
    end

    it "allows same day/service_name for different accounts" do
      existing = create(:usage_daily_account)
      other = build(:usage_daily_account, day: existing.day, service_name: existing.service_name)
      expect(other).to be_valid
    end
  end

  describe "enum service_name" do
    it "accepts valid service names" do
      Cost.service_names.keys.each do |name|
        record.service_name = name
        expect(record.service_name).to eq(name)
      end
    end
  end
end
