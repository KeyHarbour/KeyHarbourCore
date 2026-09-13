require 'rails_helper'

RSpec.describe Current, type: :model do
  fixtures :accounts, :account_users, :users
  let(:user)         { User.first }
  let(:account)      { user.account }
  let(:organization) { account.organizations.first }
  let(:project)      { organization.projects.first }
  let(:workspace)    { project.workspaces.first }
  let(:owner_role)   { user.account_user.role }
  let(:session)      { double("session", user: user) }

  before do
    Current.reset
    Current.session = session
  end

  after { Current.reset }

  describe "#user" do
    it "delegates to session" do
      expect(Current.user).to eq(user)
    end

    it "returns nil when session is nil" do
      Current.session = nil
      expect(Current.user).to be_nil
    end
  end

  describe "#account" do
    it "returns the user account" do
      expect(Current.account).to eq(account)
    end
  end

  describe "#subscription" do
    it "returns nil when no account" do
      allow(Current).to receive(:account).and_return(nil)
      expect(Current.subscription).not_to be_nil
    end

    it "returns the account subscription" do
      expect(Current.subscription).to eq(account.subscription)
    end
  end

  describe "#billing_range" do
    context "without subscription" do
      it "returns a range ending today" do
        allow(Current).to receive(:subscription).and_return(nil)
        range = Current.billing_range
        expect(range.last.to_date).to eq(Date.today)
      end
    end

    context "with subscription" do
      before { create(:account_user, user: user, account: account, role: owner_role) }

      it "returns range from period_start to today by default" do
        range = Current.billing_range
        expect(range.first.to_date).to eq(Date.current.at_beginning_of_month.to_date)
        expect(range.last.to_date).to eq(Date.today.to_date)
      end
    end
  end

  describe "#organizations" do
    before { create(:account_user, user: user, account: account, role: owner_role) }

    context "when user is Owner" do
      it "returns all account organizations" do
        expect(Current.organizations).to include(organization)
      end
    end

    context "when user is Admin" do
      let(:admin_role) { Role.find_by(name: "Admin") }
      before { user.account_user.update!(role: admin_role) }

      it "returns all account organizations" do
        expect(Current.organizations).to include(organization)
      end
    end
  end
  #
  describe "#projects" do
    before { create(:account_user, user: user, account: account, role: owner_role) }

    it "returns all account projects for Owner" do
      expect(Current.projects).to include(project)
    end
  end

  describe "#workspaces" do
    before { create(:account_user, user: user, account: account, role: owner_role) }

    it "returns all account workspaces for Owner" do
      expect(Current.workspaces).to include(workspace)
    end
  end

  describe "#users" do
    it "returns nil when no account" do
      allow(Current).to receive(:account).and_return(nil)
      expect(Current.users).not_to be_nil
    end

    it "returns account users" do
      expect(Current.users).to include(user)
    end
  end
  #
  describe "#teams" do
    it "returns nil when no account" do
      allow(Current).to receive(:account).and_return(nil)
      expect(Current.teams).not_to be_nil
    end
  end

  describe "#role / #roles" do
    it "#role returns the user role" do
      # create(:account_user, user: user, account: account, role: owner_role)
      expect(Current.role).to eq(owner_role)
    end
  end
end
