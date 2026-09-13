require 'rails_helper'

RSpec.describe  License::Application, type: :model do
  describe "associations" do
    it { should belong_to(:organization) }
    it { should have_many(:app_instances).dependent(:destroy) }
  end
end