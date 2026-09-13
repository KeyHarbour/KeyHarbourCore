require 'rails_helper'

RSpec.describe ActionLog, type: :model do
  subject(:record) { build(:action_log) }

  describe "database connection" do
    it "uses the logs database" do
      expect(ActionLog.connection_db_config.name).to eq("logs")
    end
  end

  describe "persistence" do
    it "is valid with valid attributes" do
      expect(record).to be_valid
    end

    it "persists to the logs database" do
      log = create(:action_log)
      expect(ActionLog.find(log.id)).to eq(log)
    end
  end

  describe "attributes" do
    it "stores controller, action, method_type" do
      log = create(:action_log, controller: "statefiles", action: "update", method_type: "PUT")
      expect(log.controller).to eq("statefiles")
      expect(log.action).to eq("update")
      expect(log.method_type).to eq("PUT")
    end

    it "stores user_id and organization_id" do
      log = create(:action_log, user_id: 99, organization_id: 77)
      expect(log.user_id).to eq(99)
      expect(log.organization_id).to eq(77)
    end

    it "stores action_id" do
      log = create(:action_log, action_id: 123)
      expect(log.action_id).to eq(123)
    end
  end
end
