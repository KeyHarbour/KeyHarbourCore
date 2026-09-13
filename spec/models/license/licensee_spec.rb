require 'rails_helper'

RSpec.describe  License::Licensee, type: :model do
  describe "associations" do
    it { should belong_to(:instance) }
  end
end