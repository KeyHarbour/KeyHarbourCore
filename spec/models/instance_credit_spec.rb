require 'rails_helper'

RSpec.describe InstanceCredit, type: :model do
  subject(:record) { build(:instance_credit) }

  describe "validations" do
    it { is_expected.to validate_presence_of(:day) }

    it "is valid with valid attributes" do
      expect(record).to be_valid
    end
  end
end
