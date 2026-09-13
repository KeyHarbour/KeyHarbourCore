require "rails_helper"

RSpec.describe Organization, type: :model do
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)
  end  

  describe "associations" do
    it { should belong_to(:account) }
    it { should have_many(:projects).dependent(:destroy) }
    it { should have_many(:workspaces).through(:projects) }
    # it { should have_many(:workspace_environments).through(:workspaces) }
    it { should have_many(:project_tokens).through(:projects) }
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:tags).through(:taggings) }
    it { should have_many(:tokens).dependent(:destroy) }
    it { should have_many(:environments).dependent(:destroy) }
    it { should have_many(:applications).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "#to_param" do
    it "returns the uuid" do
      organization = create(:organization)
      expect(organization.to_param).to eq(organization.uuid)
    end
  end

  describe "uuid generation" do
    it "generates uuid on creation" do
      organization = create(:organization)
      expect(organization.uuid).to be_present
    end
  end

  describe "#statefile_size" do
    it "calculates total statefile size" do
      organization = create(:organization)
      project = create(:project, organization: organization)
      workspace = create(:workspace, project: project)
      environment = create(:environment, organization: organization)
      project.environments << environment
      create(:statefile, workspace: workspace, environment: environment, content: "test content")
      
      expect(organization.statefile_size).to be > 0
    end
  end

  describe "#cost" do
    it "sums workspace environment costs" do
      organization = create(:organization)
      expect(organization.cost).to eq(0)
    end
  end

  describe "global" do
    fixtures :all 
    before(:context) do
      self.use_transactional_tests = false
    end    

    it "account number (active)" do
      expect(Organization.all.count).to eq(8)
    end 

    it "account number (unscoped)" do
      expect(Organization.unscoped.all.count).to eq(10)
    end

    it "account number (archived)" do
      expect(Organization.unscoped.archived.all.count).to eq(1)
    end

    it "account number (disabled)" do
      expect(Organization.unscoped.disabled.all.count).to eq(1)
    end

    it "account number (disabled)" do
      expect(Account.unscoped.disabled.all.count).to eq(1)
    end
  end
end
