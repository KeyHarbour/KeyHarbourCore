require 'rails_helper'

RSpec.describe Notification, type: :model do
  subject(:notification) { build(:notification) }

  describe "associations" do
    it { is_expected.to belong_to(:recipient) }
  end

  describe "scopes" do
    let!(:unread) { create(:notification, read_at: nil) }
    let!(:read)   { create(:notification, read_at: 1.hour.ago) }

    it ".unread returns only unread notifications" do
      expect(Notification.unread).to include(unread)
      expect(Notification.unread).not_to include(read)
    end

    it ".read returns only read notifications" do
      expect(Notification.read).to include(read)
      expect(Notification.read).not_to include(unread)
    end

    it ".recent returns last 5 ordered by created_at desc" do
      results = Notification.recent
      expect(results.size).to be <= 5
      expect(results).to eq(results.sort_by(&:created_at).reverse)
    end
  end

  describe "#read?" do
    it "returns false when read_at is nil" do
      notification.read_at = nil
      expect(notification.read?).to be false
    end

    it "returns true when read_at is set" do
      notification.read_at = Time.current
      expect(notification.read?).to be true
    end
  end

  describe "#unread?" do
    it "returns true when read_at is nil" do
      notification.read_at = nil
      expect(notification.unread?).to be true
    end

    it "returns false when read_at is set" do
      notification.read_at = Time.current
      expect(notification.unread?).to be false
    end
  end

  describe "#mark_as_read!" do
    it "sets read_at to current time" do
      n = create(:notification, read_at: nil)
      expect { n.mark_as_read! }.to change { n.read_at }.from(nil)
      expect(n.read_at).to be_within(2.seconds).of(Time.current)
    end
  end
end
