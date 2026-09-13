class SubscriptionCredit < ApplicationRecord
  EVENTS = {
    initial: :initial,
    renewal: :renewal,
    cancellation: :cancellation,
    free: :free,
    used: :used
  }
  belongs_to :subscription
  enum :event, SubscriptionCredit::EVENTS
  before_create :assign_uuid

  def self.add(credits, event, month = Date.current)
    order = self.count
    credit_balance = self.order(order: :desc).first&.credit_balance || 0
    credit_balance += credits
    self.create(
      month: month.at_beginning_of_month,
      credits: credits,
      event: event,
      credit_balance: credit_balance,
      order: order + 1)
  end

  private

  def assign_uuid
    # UUID format YY-MM-EVENT-ORDER-UUID
    self.uuid = "#{self.month.strftime("%Y-%m")}-#{self.event}-#{self.order}-#{SecureRandom.uuid}"
  end
end
