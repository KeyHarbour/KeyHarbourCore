require 'rails_helper'

RSpec.describe KeyValueStore, type: :model do
  describe "associations" do
    it { should belong_to(:workspace) }
    it { should belong_to(:environment) }
  end
end
