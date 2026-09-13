require 'rails_helper'

RSpec.describe Plan, type: :model do
  describe ".all" do
    it "returns a non-empty list of plans" do
      expect(Plan.all).not_to be_empty
    end

    it "returns Plan instances" do
      expect(Plan.all).to all(be_a(Plan))
    end
  end

  describe ".find" do
    it "returns the plan with the given id" do
      plan = Plan.find("free")
      expect(plan.id).to eq("free")
    end

    it "raises RecordNotFound for unknown id" do
      expect { Plan.find("nonexistent") }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe ".where" do
    it "filters plans by attribute" do
      results = Plan.where(id: "free")
      expect(results.map(&:id)).to eq(["free"])
    end
  end

  describe "attributes" do
    subject(:plan) { Plan.find("free") }

    it "has a price" do
      expect(plan.price).to be_a(Numeric)
    end

    it "has credits" do
      expect(plan.credits).to be_a(Integer)
    end

    it "has an order" do
      expect(plan.order).to be_a(Integer)
    end
  end

  describe "#full_name" do
    it "prefixes name with KH -" do
      plan = Plan.find("free")
      expect(plan.full_name).to start_with("KH - ")
    end
  end
end
