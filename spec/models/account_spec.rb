require "rails_helper"

RSpec.describe Account, type: :model do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end    

  describe "associations" do
    it { should have_many(:account_users).dependent(:destroy) }
    it { should have_many(:users).through(:account_users).dependent(:destroy) }
    it { should have_many(:organizations).dependent(:destroy) }
    it { should have_many(:teams).dependent(:destroy) }
    it { should have_many(:applications).through(:organizations) }
    it { should have_many(:app_team_members).through(:organizations) }
    it { should have_many(:model_categories).through(:organizations) }
    it { should have_many(:model_families).through(:organizations) }
    it { should have_many(:project_tokens).through(:organizations) }
    it { should have_many(:organization_tokens).through(:organizations) }
    it { should have_many(:projects).through(:organizations) }
    it { should have_many(:app_instances).through(:applications) }
    it { should have_many(:model_category_attrs).through(:model_categories) }
    it { should have_many(:workspaces).through(:projects) }
    it { should have_many(:trust_assets).through(:workspaces) }
  end

  describe "global" do
    fixtures :all 
    before(:context) do
      self.use_transactional_tests = false
    end    

    it "account number" do
      expect(Account.all.count).to eq(4)
    end

    it "users kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").users.count).to eq(13)
    end

    it "admin kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").admins.count).to eq(3)
    end

    it "owner kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").owners.count).to eq(1)
    end

    it "viewer kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").viewers.count).to eq(2)
    end

    it "inactive kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").inactives.count).to eq(1)
    end

    it "users building" do
      expect(Account.find_by(name: "Building").users.count).to eq(4)
    end

    it "org kh" do
      expect(Account.find_by(name: "KeyHarbour Inc").organizations.count).to eq(2)
    end
  end
end