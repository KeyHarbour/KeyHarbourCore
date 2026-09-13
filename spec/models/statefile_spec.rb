require "rails_helper"

RSpec.describe Statefile, type: :model do
  describe "associations" do
    it { should belong_to(:workspace) }
    it { should belong_to(:environment) }
    it { should have_one(:statefile_tag).dependent(:destroy) }
  end

  describe "validations" do
    subject { create(:statefile) }
    it { should validate_uniqueness_of(:uuid).scoped_to(:workspace_id) }
  end

  describe "uuid generation" do
    it "generates unique uuid on creation" do
      statefile = create(:statefile)
      expect(statefile.uuid).to be_present
      expect(statefile.uuid).to include("-")
    end
  end

  describe ".new_version" do
    let(:workspace) { create(:workspace) }
    let(:environment) { create(:environment, organization: workspace.organization) }

    before do
      workspace.project.environments << environment
    end

    it "creates new statefile version" do
      content = '{"version": 4, "resources": []}'
      expect {
        Statefile.new_version(workspace: workspace, environment: environment, content: content)
      }.to change(Statefile, :count).by(1)
    end

    it "raises error for unavailable environment" do
      other_env = create(:environment, organization: workspace.organization)
      expect {
        Statefile.new_version(workspace: workspace, environment: other_env, content: "{}")
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe "#pretty_content" do
    it "returns formatted JSON" do
      statefile = create(:statefile, content: '{"test":"value"}')
      expect(statefile.pretty_content).to include("test")
      expect(statefile.pretty_content).to include("value")
    end

    it "returns empty object for invalid JSON" do
      statefile = create(:statefile, content: "invalid json")
      expect(statefile.pretty_content).to eq("{}")
    end
  end

  describe "#lines_count" do
    it "counts lines in pretty content" do
      statefile = create(:statefile, content: '{"test":"value"}')
      expect(statefile.lines_count).to be > 0
    end
  end

  describe "#resource_count" do
    it "returns 0 for empty resources" do
      statefile = create(:statefile, content: '{"resources":[]}')
      expect(statefile.resource_count).to eq(0)
    end

    it "counts resources" do
      statefile = create(:statefile, content: '{"resources":[{"type":"aws_instance", "instances": []},{"type":"aws_s3_bucket"}]}')
      expect(statefile.resource_count).to eq(2)
    end
  end

  describe "#parsed_content" do
    it "parses JSON content" do
      statefile = create(:statefile, content: '{"test":"value"}')
      expect(statefile.parsed_content).to eq({"test" => "value"})
    end

    it "returns empty hash for invalid JSON" do
      statefile = create(:statefile, content: "invalid")
      expect(statefile.parsed_content).to eq({})
    end
  end
end
