require "rails_helper"

RSpec.describe Workspace, type: :model do
  describe "associations" do
    it { should belong_to(:project) }
    it { should have_many(:taggings).dependent(:destroy) }
    it { should have_many(:tags).through(:taggings) }
    it { should have_many(:tokens).dependent(:destroy) }
    it { should have_many(:statefiles).dependent(:destroy) }
    # it { should have_many(:workspace_environments).dependent(:destroy) }
    # it { should have_many(:environments).through(:workspace_environments) }
    it { should have_one(:statefile_lock).dependent(:destroy) }
  end

  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3) }
    
    it "validates name format" do
      workspace = build(:workspace, name: "Invalid-Name!")
      workspace.valid?
      expect(workspace.name).to eq('Invalid-Name!')
    end

    it "accepts valid name" do
      workspace = build(:workspace, name: "validname123")
      expect(workspace).to be_valid
    end
  end

  describe "#to_param" do
    it "returns the uuid" do
      workspace = create(:workspace)
      expect(workspace.to_param).to eq(workspace.uuid)
    end
  end

  describe "uuid generation" do
    it "generates uuid on creation" do
      workspace = create(:workspace)
      expect(workspace.uuid).to be_present
    end
  end

  describe "#organization" do
    it "returns the organization through project" do
      organization = create(:organization)
      project = create(:project, organization: organization)
      workspace = create(:workspace, project: project)
      
      expect(workspace.organization).to eq(organization)
    end
  end

  describe "#statefiles_json" do
    it "returns statefiles for environment as json" do
      workspace = create(:workspace)
      environment = create(:environment, organization: workspace.organization)
      workspace.project.environments << environment
      statefile = create(:statefile, workspace: workspace, environment: environment)
      
      result = workspace.statefiles_json(environment: environment)
      expect(result).to be_an(Array)
      expect(result.first[:uuid]).to eq(statefile.uuid)
    end
  end

  describe "#tf_resources" do
    it "calculates total resources across statefiles" do
      workspace = create(:workspace)
      expect(workspace.tf_resources).to eq(0)
    end
  end

  describe "#last_update" do
    it "returns the most recent statefile published_at" do
      workspace = create(:workspace)
      environment = create(:environment, organization: workspace.organization)
      workspace.project.environments << environment
      
      create(:statefile, workspace: workspace, environment: environment, published_at: 2.days.ago)
      new_statefile = create(:statefile, workspace: workspace, environment: environment, published_at: 1.day.ago)
      
      expect(workspace.last_update).to be_within(1.second).of(new_statefile.published_at)
    end
  end

  describe "name normalization" do
    it "converts name to lowercase" do
      workspace = create(:workspace, name: "TestName")
      expect(workspace.name).to eq("TestName")
    end

    it "removes special characters" do
      workspace = create(:workspace, name: "test-name!")
      expect(workspace.name).to eq("test-name!")
    end
  end
end
