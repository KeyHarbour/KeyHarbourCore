require 'rails_helper'

RSpec.describe User, type: :model do
  before do
    Role.create(name: 'Owner') if Role.find_by(name: 'Owner').nil?
    Role.create(name: 'Admin') if Role.find_by(name: 'Admin').nil?
    Role.create(name: 'User') if Role.find_by(name: 'User').nil?
    Role.create(name: 'Viewer') if Role.find_by(name: 'Viewer').nil?
  end

  describe "associations" do
    it { is_expected.to have_many(:sessions).dependent(:destroy) }
    it { is_expected.to have_many(:team_users) }
    it { is_expected.to have_many(:teams).through(:team_users) }
    it { is_expected.to have_many(:projects).through(:account_organizations) }
    it { is_expected.to have_many(:workspaces).through(:projects) }
    it { is_expected.to have_one(:account_user).dependent(:destroy) }
    it { is_expected.to have_one(:account).through(:account_user) }
    it { is_expected.to have_many(:notifications) }
  end

  describe "validations" do
    subject { create(:user) }
    it { is_expected.to have_secure_password }
    it { is_expected.to validate_presence_of(:email_address) }
    it { is_expected.to validate_uniqueness_of(:email_address).ignoring_case_sensitivity }

    it "normalises email (strip + downcase)" do
      user = create(:user, email_address: "  TEST@Example.com  ")
      expect(user.email_address).to eq("test@example.com")
    end
  end

  describe "enums" do
    it { is_expected.to define_enum_for(:global_role).with_values(admin: 0, default: 254, desactivated: 255) }
  end

  describe "instance methods" do
    let(:user) { build(:user, email_address: "jean.dupont@provider.com") }

    it "#name returns email_address" do
      expect(user.name).to eq("jean.dupont@provider.com")
    end

    it "#full_name titleizes the local part of the email" do
      expect(user.full_name).to eq("Jean.Dupont")
    end
  end

  describe "#account_admin?" do
    let(:account) { create(:account) }
    let(:user)    { create(:user) }

    it "returns true for global admin" do
      user.update!(global_role: :admin)
      expect(user.account_admin?).to be true
    end

    it "returns true when account_user role is Owner" do
      create(:account_user, user: user, account: account, role: Role.find_by(name: 'Owner'))
      expect(user.account_admin?).to be true
    end

    it "returns true when account_user role is Admin" do
      create(:account_user, user: user, account: account, role: Role.find_by(name: 'Admin'))
      expect(user.account_admin?).to be true
    end

    it "returns false for a Viewer" do
      create(:account_user, user: user, account: account, role: Role.find_by(name: 'Viewer'))
      expect(user.account_admin?).to be false
    end
  end

  describe "#workspace_edit / #workspace_view" do
    let(:user)      { create(:user) }
    let(:workspace) { create(:workspace) }

    it "#workspace_view returns false when no permissions" do
      allow(user).to receive(:workspace_permissions).with(workspace).and_return(nil)
      expect(user.workspace_view(workspace)).to be false
    end

    it "#workspace_edit returns false when viewer" do
      allow(user).to receive(:workspace_permissions).with(workspace).and_return(:viewer)
      expect(user.workspace_edit(workspace)).to be false
    end

    it "#workspace_edit returns true when editor" do
      allow(user).to receive(:workspace_permissions).with(workspace).and_return(:editor)
      expect(user.workspace_edit(workspace)).to be true
    end
  end

  describe "#project_edit / #project_view" do
    let(:user)    { create(:user) }
    let(:project) { create(:project) }

    it "#project_view returns false when no permissions" do
      allow(user).to receive(:project_permissions).with(project).and_return(nil)
      expect(user.project_view(project)).to be false
    end

    it "#project_edit returns true when admin" do
      allow(user).to receive(:project_permissions).with(project).and_return(:admin)
      expect(user.project_edit(project)).to be true
    end
  end

  describe "#do_something_if_email_changed (before_save)" do
    it "sets email_verified to false when email changes" do
      user = create(:user, email_address: "old@example.com")
      user.update!(email_address: "new@example.com")
      expect(user.email_verified).to be false
    end
  end
end

RSpec.describe User, "permissions hierarchy", type: :model do
  let(:account)      { create(:account) }
  let(:organization) { create(:organization, account: account) }
  let(:project)      { create(:project, organization: organization) }
  let(:workspace)    { create(:workspace, project: project) }
  let(:team)         { create(:team) }
  let(:user)         { create(:user) }
  let!(:team_user)   { create(:team_user, team: team, user: user) }

  context "when user is account admin" do
    before { allow(user).to receive(:account_admin?).and_return(true) }

    it "returns :admin for organization, project and workspace" do
      expect(user.organization_permissions(organization)).to eq(:admin)
      expect(user.project_permissions(project)).to eq(:admin)
      expect(user.workspace_permissions(workspace)).to eq(:admin)
    end
  end

  context "when user has no roles" do
    before { allow(user).to receive(:account_admin?).and_return(false) }

    it "returns nil for organization, project and workspace" do
      expect(user.organization_permissions(organization)).to be_nil
      expect(user.project_permissions(project)).to be_nil
      expect(user.workspace_permissions(workspace)).to be_nil
    end
  end

  [:admin, :editor, :viewer].each do |role|
    context "with organization-level #{role} team role" do
      let!(:team_role) { create(:team_role, :with_org, team: team, resource: organization, role: role) }

      before { allow(user).to receive(:account_admin?).and_return(false) }

      it "returns #{role} for organization, project and workspace" do
        expect(user.organization_permissions(organization)).to eq(role)
        expect(user.project_permissions(project)).to eq(role)
        expect(user.workspace_permissions(workspace)).to eq(role)
      end
    end

    context "with project-level #{role} team role" do
      let!(:team_role) { create(:team_role, :with_prj, team: team, resource: project, role: role) }

      before { allow(user).to receive(:account_admin?).and_return(false) }

      it "returns nil for organization but #{role} for project and workspace" do
        expect(user.organization_permissions(organization)).to be_nil
        expect(user.project_permissions(project)).to eq(role)
        expect(user.workspace_permissions(workspace)).to eq(role)
      end
    end

    context "with workspace-level #{role} team role" do
      let!(:team_role) { create(:team_role, :with_wks, team: team, resource: workspace, role: role) }

      before { allow(user).to receive(:account_admin?).and_return(false) }

      it "returns nil for organization and project but #{role} for workspace" do
        expect(user.organization_permissions(organization)).to be_nil
        expect(user.project_permissions(project)).to be_nil
        expect(user.workspace_permissions(workspace)).to eq(role)
      end
    end
  end
end
