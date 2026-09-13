require 'rails_helper'

RSpec.describe ApiQuery, type: :model do
  subject(:record) { build(:api_query) }

  describe "associations" do
    it { is_expected.to belong_to(:serviceable) }
  end

  describe "enum service_name" do
    it "accepts valid service names" do
      Cost.service_names.keys.each do |name|
        record.service_name = name
        expect(record.service_name).to eq(name)
      end
    end

    it "rejects unknown service_name" do
      expect { record.service_name = :unknown }.to raise_error(ArgumentError)
    end
  end

  describe "default_scope" do
    it "orders by date asc" do
      expect(ApiQuery.all.to_sql).to include("date\" ASC")
    end
  end
end
