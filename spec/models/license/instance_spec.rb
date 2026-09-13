require 'rails_helper'

RSpec.describe  License::Instance, type: :model do
  describe "associations" do
    it { should belong_to(:application) }
    it { should have_many(:licensees).dependent(:destroy) }
  end
end