require 'rails_helper'

RSpec.describe TokenProject, type: :model do
  it { should belong_to(:environment) }
  let(:workspace) { create(:workspace) }
  let(:project) { workspace.project }
  let(:organization) { project.organization }

  describe 'validations' do
    it 'is valid when scopable is an Project' do
      token = build(:token_project, scopable: project)
      expect(token).to be_valid
    end

    it 'is invalid when scopable is not an Project' do
      token = build(:token_project, scopable: workspace)
      expect(token).not_to be_valid
      expect(token.errors[:scopable]).to include('must be a Project')
    end
  end

  describe '#account' do
    it 'returns the associated scopable' do
      token = build(:token_project, scopable: project)
      expect(token.project).to eq(project)
    end
  end

  describe ".find_workspace_by_token" do
    context "when token is nil or invalid" do
      it "returns nil" do
        expect(described_class.find_workspace_by_token(project.uuid, "invalid_token")).to be_nil
      end
    end

    context "when token belongs to a Project" do
      let(:token) { create(:token_project, scopable: project, expiration: 1.day.from_now) }

      it "returns the project if UUID matches (case-insensitive)" do
        token_str = token.generate_token_for(:statefile)
        expect(described_class.find_workspace_by_token(project.workspaces.first.uuid, token_str)).to eq(workspace)
      end

      it "returns nil if UUID does not match" do
        token_str = token.generate_token_for(:statefile)
        expect(described_class.find_workspace_by_token("other-uuid", token_str)).to be_nil
      end
    end
  end  
end




