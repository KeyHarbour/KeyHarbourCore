require 'rails_helper'

RSpec.describe TokenWorkspace, type: :model do
  it { should belong_to(:environment) }
  let(:workspace) { create(:workspace) }
  let(:project) { create(:project) }

  describe 'validations' do
    it 'is valid when scopable is an Workspace' do
      token = build(:token_workspace, scopable: workspace)
      expect(token).to be_valid
    end

    it 'is invalid when scopable is not an Workspace' do
      token = build(:token_workspace, scopable: project)
      expect(token).not_to be_valid
      expect(token.errors[:scopable]).to include('must be a Workspace')
    end
  end

  describe '#account' do
    it 'returns the associated scopable' do
      token = build(:token_workspace, scopable: workspace)
      expect(token.workspace).to eq(workspace)
    end
  end

  describe ".find_workspace_by_token" do
    let(:workspace) { create(:workspace, project: project) }

    context "when token is nil or invalid" do
      it "returns nil" do
        expect(described_class.find_workspace_by_token(workspace.uuid, "invalid_token")).to be_nil
      end
    end

    context "when token belongs to a Workspace" do
      let(:token) { create(:token_workspace, scopable: workspace, expiration: 1.day.from_now) }

      it "returns the workspace if UUID matches (case-insensitive)" do
        token_str = token.generate_token_for(:statefile)
        expect(described_class.find_workspace_by_token(workspace.uuid.upcase, token_str)).to eq(workspace)
      end

      it "returns nil if UUID does not match" do
        token_str = token.generate_token_for(:statefile)
        expect(described_class.find_workspace_by_token("other-uuid", token_str)).to be_nil
      end
    end
  end  
end




