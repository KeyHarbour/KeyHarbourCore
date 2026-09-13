require 'rails_helper'

RSpec.describe SubscriptionCredit, type: :model do
  subject(:record) { build(:subscription_credit) }

  describe "associations" do
    it { is_expected.to belong_to(:subscription) }
  end

  describe "enum event" do
    it "accepts all defined events" do
      SubscriptionCredit::EVENTS.keys.each do |ev|
        record.event = ev
        expect(record.event).to eq(ev.to_s)
      end
    end

    it "rejects unknown event" do
      expect { record.event = :unknown }.to raise_error(ArgumentError)
    end
  end

  describe "#assign_uuid (before_create)" do
    it "generates a uuid on create" do
      credit = create(:subscription_credit)
      expect(credit.uuid).to match(/\A\d{4}-\d{2}-initial-\d+-/)
    end

    it "uuid includes month, event and order" do
      credit = create(:subscription_credit, month: Date.new(2025, 3, 1), event: :renewal, order: 5)
      expect(credit.uuid).to start_with("2025-03-renewal-5-")
    end
  end

  describe ".add" do
    let(:subscription) { create(:subscription) }

    it "creates a credit with correct balance when ledger is empty" do
      credit = subscription.subscription_credits.add(50, :initial)
      expect(credit.credits).to eq(50)
      expect(credit.credit_balance).to eq(50)
    end

    it "accumulates credit_balance from previous entry" do
      subscription.subscription_credits.add(50, :initial)
      credit = subscription.subscription_credits.add(20, :renewal)
      expect(credit.credit_balance).to eq(70)
    end

    it "decrements balance with negative credits" do
      subscription.subscription_credits.add(50, :initial)
      credit = subscription.subscription_credits.add(-10, :used)
      expect(credit.credit_balance).to eq(40)
    end
  end
end
