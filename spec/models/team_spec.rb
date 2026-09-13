require "rails_helper"

RSpec.describe Team, type: :model do
  describe "associations" do
    it { should belong_to(:account) }
    it { should have_many(:team_roles).dependent(:destroy) }
    it { should have_many(:team_users) }
    it { should have_many(:users).through(:team_users) }
  end

  describe "validations" do
    subject { build(:team) }
    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:account_id) }
  end

  describe "enums" do
    it { should define_enum_for(:source).with_values(local: 0, active_directory: 1) }
  end

  describe "#to_param" do
    it "returns the uuid" do
      team = create(:team)
      expect(team.to_param).to eq(team.uuid)
    end
  end

  describe "uuid generation" do
    it "generates uuid on creation" do
      team = create(:team)
      expect(team.uuid).to be_present
    end
  end
end
