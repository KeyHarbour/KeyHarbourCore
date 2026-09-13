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

  describe "#get_expire_in" do
    it "returns seconds until expiration" do
      token = create(:token, :for_project, expiration: 1.hour.from_now)
      expect(token.get_expire_in).to be_within(5).of(3600)
    end
  end

  # describe ".validate?" do
  #   let(:organization) { create(:organization) }
  #   let(:project) { create(:project, organization: organization) }
  #   let(:environment) { create(:environment, organization: organization) }
  #   let(:token) { create(:token, :for_project, environment: environment, expiration: 1.day.from_now) }

  #   it "returns true for valid token" do
  #     token_str = token.generate_token_for(:statefile)
  #     expect(Token.validate?(organization.uuid, project.uuid, token_str)).to be true
  #   end

  #   it "returns false for expired token" do
  #     expired_token = create(:token, scopable: project, environment: environment, expiration: 1.day.ago)
  #     token_str = expired_token.generate_token_for(:statefile)
  #     expect(Token.validate?(organization.uuid, project.uuid, token_str)).to be false
  #   end

  #   it "returns false for invalid organization" do
  #     token_str = token.generate_token_for(:statefile)
  #     expect(Token.validate?("invalid-uuid", project.uuid, token_str)).to be false
  #   end
  # end

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
end
