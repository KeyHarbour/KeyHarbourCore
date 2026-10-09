require "rails_helper"

RSpec.describe Token, type: :model do
  describe "associations" do
    it { should belong_to(:scopable) }
    it { should belong_to(:environment).optional }
  end

  describe "validations" do
    subject { build(:token, :for_project) }
    
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name).scoped_to(:scopable_type, :scopable_id) }
    it { should validate_presence_of(:expiration) }
    it { should validate_presence_of(:scopable_type) }
    it { should validate_presence_of(:scopable_id) }
  end

  describe "virtual attribute setters" do
    let(:organization) { create(:organization) }
    let(:project) { create(:project) }
    let(:workspace) { create(:workspace) }

    describe "#organization_id=" do
      it "sets scopable to Organization when value is present and scopable is not Project or Workspace" do
        token2 = Token.new
        token2.organization_id = organization.id
        expect(token2.scopable_type).to eq("Organization")
        expect(token2.scopable_id).to eq(organization.id)
      end

      it "does nothing if value is blank" do
        token = Token.new
        token.organization_id = ""
        expect(token.scopable_type).to be_nil
      end

      it "does not overwrite if scopable_type is Project or Workspace" do
        token = Token.new(scopable: project)
        token.organization_id = organization.id
        expect(token.scopable_type).to eq("Project")
      end
    end

    describe "#workspace_id=" do
      it "sets scopable to Workspace" do
        token = Token.new
        token.workspace_id = workspace.id
        expect(token.scopable_type).to eq("Workspace")
        expect(token.scopable_id).to eq(workspace.id)
      end

      it "does nothing if value is blank" do
        token = Token.new
        token.workspace_id = nil
        expect(token.scopable_type).to be_nil
      end
    end

    describe "#project_id=" do
      it "sets scopable to Project" do
        token = Token.new
        token.project_id = project.id
        expect(token.scopable_type).to eq("Project")
        expect(token.scopable_id).to eq(project.id)
      end

      it "does not set if scopable_type is already Workspace" do
        token = Token.new(scopable: workspace)
        token.project_id = project.id
        expect(token.scopable_type).to eq("Workspace")
      end

      it "does nothing if value is blank" do
        token = Token.new
        token.project_id = ""
        expect(token.scopable_type).to be_nil
      end
    end
  end

  describe "#get_expire_in" do
    it "returns seconds until expiration" do
      token = create(:token, :for_project, expiration: 1.hour.from_now)
      expect(token.get_expire_in).to be_within(5).of(3600)
    end
  end

  describe "token predicate methods" do
    it "#project_token?" do
      token = build(:token, scopable_type: "Project")
      expect(token.project_token?).to be true
    end

    it "#organization_token?" do
      env = create(:environment)
      token = build(:token, scopable_type: "Organization", environment: env)
      expect(token.organization_token?).to be true

      token_no_env = build(:token, scopable_type: "Organization", environment: nil)
      expect(token_no_env.organization_token?).to be false
    end

    it "#workspace_token?" do
      token = build(:token, scopable_type: "Workspace")
      expect(token.workspace_token?).to be true
    end

    it "#application_token?" do
      token = build(:token, scopable_type: "Organization", environment: nil)
      expect(token.application_token?).to be true

      env = create(:environment)
      token_with_env = build(:token, scopable_type: "Organization", environment: env)
      expect(token_with_env.application_token?).to be false
    end
  end

  describe ".check" do
    let(:token) { create(:token, :for_project, expiration: 1.day.from_now) }

    it "returns token for valid token string" do
      token_str = token.generate_token_for(:statefile)
      expect(Token.check(token_str)).to eq(token)
    end

    it "returns nil for expired token" do
      expired_token = create(:token, :for_project, expiration: 1.day.ago)
      token_str = expired_token.generate_token_for(:statefile)
      expect(Token.check(token_str)).to be_nil
    end
  end

  describe ".find_workspace_by_token" do
    let(:organization) { create(:organization) }
    let(:project) { create(:project, organization: organization) }
    let(:workspace) { create(:workspace, project: project) }

    context "when token is nil or invalid" do
      it "returns nil" do
        expect(Token.find_workspace_by_token(workspace.uuid, "invalid_token")).to be_nil
      end
    end

    context "when token belongs to a Project" do
      let(:token) { create(:token, scopable: project, expiration: 1.day.from_now) }

      it "returns the workspace if it belongs to the project" do
        token_str = token.generate_token_for(:statefile)
        expect(Token.find_workspace_by_token(workspace.uuid, token_str)).to eq(workspace)
      end

      it "returns nil if workspace does not belong to the project" do
        other_workspace = create(:workspace)
        token_str = token.generate_token_for(:statefile)
        expect(Token.find_workspace_by_token(other_workspace.uuid, token_str)).to be_nil
      end
    end

    context "when token belongs to an Organization" do
      let(:token) { create(:token, scopable: organization, expiration: 1.day.from_now) }

      it "finds workspace by organization" do
        allow(organization).to receive(:workspaces).and_return(Workspace.where(id: workspace.id))
        token_str = token.generate_token_for(:statefile)
        expect(Token.find_workspace_by_token(workspace.uuid, token_str)).to eq(workspace)
      end
    end

    context "when token belongs to a Workspace" do
      let(:token) { create(:token, scopable: workspace, expiration: 1.day.from_now) }

      it "returns the workspace if UUID matches (case-insensitive)" do
        token_str = token.generate_token_for(:statefile)
        expect(Token.find_workspace_by_token(workspace.uuid.upcase, token_str)).to eq(workspace)
      end

      it "returns nil if UUID does not match" do
        token_str = token.generate_token_for(:statefile)
        expect(Token.find_workspace_by_token("other-uuid", token_str)).to be_nil
      end
    end
  end
end