require 'rails_helper'

RSpec.describe SubscriptionCoupon, type: :model do
  subject(:record) { build(:subscription_coupon) }

  describe "associations" do
    it { is_expected.to belong_to(:subscription) }
    it { is_expected.to belong_to(:coupon) }
  end

  it "is valid with valid attributes" do
    expect(record).to be_valid
  end
end
