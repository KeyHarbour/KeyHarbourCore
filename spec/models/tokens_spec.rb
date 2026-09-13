require 'rails_helper'

RSpec.describe Token, type: :model do
  it "is valid" do
    token = create(:token, :for_project)
    expect(token).to be_present
    expect(token.scopable).to be_a(Project)
  end
  it "is invalid without a name" do
    token = Token.new(name: nil)
    expect(token).not_to be_valid
  end
end