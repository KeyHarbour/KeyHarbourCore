require 'rails_helper'

RSpec.describe UsageDailyProject, type: :model do
  subject(:record) { build(:usage_daily_project) }

  describe "associations" do
    it { is_expected.to belong_to(:project) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }

    it "is invalid without a service_name" do
      record.service_name = nil
      expect(record).not_to be_valid
    end

    it "rejects duplicate day/project/service_name" do
      existing = create(:usage_daily_project)
      duplicate = build(:usage_daily_project, project: existing.project, day: existing.day, service_name: existing.service_name)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:day]).to be_present
    end

    it "allows same day with different service_name" do
      existing = create(:usage_daily_project)
      other = build(:usage_daily_project, project: existing.project, day: existing.day, service_name: "Statefile")
      expect(other).to be_valid
    end

    it "allows same day/service_name for different projects" do
      existing = create(:usage_daily_project)
      other = build(:usage_daily_project, day: existing.day, service_name: existing.service_name)
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
