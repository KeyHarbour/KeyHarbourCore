require 'rails_helper'

RSpec.describe UsageDailyOrganization, type: :model do
  subject(:record) { build(:usage_daily_organization) }

  describe "associations" do
    it { is_expected.to belong_to(:organization) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }

    it "is invalid without a service_name" do
      record.service_name = nil
      expect(record).not_to be_valid
    end

    it "rejects duplicate day/organization/service_name" do
      existing = create(:usage_daily_organization)
      duplicate = build(:usage_daily_organization, organization: existing.organization, day: existing.day, service_name: existing.service_name)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:day]).to be_present
    end

    it "allows same day with different service_name" do
      existing = create(:usage_daily_organization)
      other = build(:usage_daily_organization, organization: existing.organization, day: existing.day, service_name: "Statefile")
      expect(other).to be_valid
    end

    it "allows same day/service_name for different organizations" do
      existing = create(:usage_daily_organization)
      other = build(:usage_daily_organization, day: existing.day, service_name: existing.service_name)
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
