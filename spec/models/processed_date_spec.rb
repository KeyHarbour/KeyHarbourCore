require 'rails_helper'

RSpec.describe ProcessedDate, type: :model do
  subject(:record) { build(:processed_date) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }
    it { is_expected.to validate_uniqueness_of(:day) }

    it "rejects duplicate day" do
      existing = create(:processed_date)
      duplicate = build(:processed_date, day: existing.day)
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:day]).to be_present
    end

    it "allows different days" do
      create(:processed_date, day: Date.today)
      other = build(:processed_date, day: Date.yesterday)
      expect(other).to be_valid
    end
  end
end
