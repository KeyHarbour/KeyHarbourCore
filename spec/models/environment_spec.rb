require "rails_helper"

RSpec.describe Environment, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
    it { should have_and_belong_to_many(:projects) }
    it { should have_many(:workspace_environments).dependent(:destroy) }
  end

  describe "validations" do
    subject { build(:environment) }
    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:organization_id).case_insensitive }
  end

  describe "creation" do
    it "is valid with valid attributes" do
      environment = create(:environment)
      expect(environment).to be_valid
      expect(environment).to be_persisted
    end

    it "is invalid without a name" do
      environment = build(:environment, name: nil)
      expect(environment).not_to be_valid
      expect(environment.errors[:name]).to include("can't be blank")
    end

    it "is invalid with duplicate name in same organization" do
      organization = create(:organization)
      create(:environment, name: "staging", organization: organization)
      duplicate = build(:environment, name: "staging", organization: organization)
      
      expect(duplicate).not_to be_valid
      expect(duplicate.errors[:name]).to include("has already been taken")
    end

    it "allows duplicate name in different organizations" do
      org1 = create(:organization)
      org2 = create(:organization)
      
      create(:environment, name: "production", organization: org1)
      env2 = build(:environment, name: "production", organization: org2)
      
      expect(env2).to be_valid
    end

    it "validates uniqueness case insensitively" do
      organization = create(:organization)
      create(:environment, name: "Production", organization: organization)
      duplicate = build(:environment, name: "production", organization: organization)
      
      expect(duplicate).not_to be_valid
    end
  end
end
