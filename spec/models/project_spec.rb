require "rails_helper"

RSpec.describe Project, type: :model do
  fixtures :all
  before(:all) do
    DatabaseCleaner.clean_with(:truncation)

  end  

  describe "associations" do
    it { should belong_to(:organization) }
    it { should have_many(:workspaces).dependent(:destroy) }
    # it { should have_many(:workspace_environments).through(:workspaces) }
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:tags).through(:taggings) }
    it { should have_many(:tokens).dependent(:destroy) }
    # it { should have_many(:team_projects).dependent(:destroy) }
    # it { should have_many(:teams).through(:team_projects) }
    it { should have_and_belong_to_many(:environments) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
  end

  describe "#to_param" do
    it "returns the uuid" do
      project = create(:project)
      expect(project.to_param).to eq(project.uuid)
    end
  end

  describe "uuid generation" do
    it "generates uuid on creation" do
      project = create(:project)
      expect(project.uuid).to be_present
    end
  end

  describe "#environment_names" do
    it "returns array of environment names" do
      project = create(:project)
      env1 = create(:environment, organization: project.organization, name: "production")
      env2 = create(:environment, organization: project.organization, name: "staging")
      project.environments << [env1, env2]
      
      expect(project.environment_names).to match_array(["production", "staging"])
    end
  end

  describe "#workspaces_json" do
    it "returns workspaces as json array" do
      project = create(:project)
      workspace = create(:workspace, project: project)
      
      result = project.workspaces_json
      expect(result).to be_an(Array)
      expect(result.first[:uuid]).to eq(workspace.uuid)
      expect(result.first[:name]).to eq(workspace.name)
    end
  end

  describe "team associations" do
    let(:project) { create(:project) }
    let(:account) { create(:account) }
    let(:admin_team) { create(:team, account: account) }
    let(:contributor_team) { create(:team, account: account) }
    let(:reader_team) { create(:team, account: account) }

    before do
      create(:team_project, team: admin_team, project: project, role: :admin)
      create(:team_project, team: contributor_team, project: project, role: :contributor)
      create(:team_project, team: reader_team, project: project, role: :reader)
    end
  end

  describe "global" do
    fixtures :all 
    before(:context) do
      self.use_transactional_tests = false
    end    

    it "account number (active)" do
      expect(Project.all.count).to eq(12)
    end 

    it "account number (unscoped)" do
      expect(Project.unscoped.all.count).to eq(13)
    end

    it "account number (archived)" do
      expect(Project.unscoped.archived.all.count).to eq(1)
    end

    it "account number (disabled)" do
      expect(Project.unscoped.disabled.all.count).to eq(2)
    end
  end
end
