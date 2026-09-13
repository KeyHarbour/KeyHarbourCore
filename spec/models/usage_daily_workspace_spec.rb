require 'rails_helper'

RSpec.describe UsageDailyWorkspace, type: :model do
  subject(:record) { build(:usage_daily_workspace) }

  describe "associations" do
    it { is_expected.to belong_to(:workspace) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }

    it "is invalid without a service_name" do
      record.service_name = nil
      expect(record).not_to be_valid
    end

    it "rejects duplicate day/workspace/service_name" do
      existing = create(:usage_daily_workspace)
      duplicate = build(:usage_daily_workspace, workspace: existing.workspace, day: existing.day, service_name: existing.service_name)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:day]).to be_present
    end

    it "allows same day with different service_name" do
      existing = create(:usage_daily_workspace)
      other = build(:usage_daily_workspace, workspace: existing.workspace, day: existing.day, service_name: "Statefile")
      expect(other).to be_valid
    end

    it "allows same day/service_name for different workspaces" do
      existing = create(:usage_daily_workspace)
      other = build(:usage_daily_workspace, day: existing.day, service_name: existing.service_name)
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
