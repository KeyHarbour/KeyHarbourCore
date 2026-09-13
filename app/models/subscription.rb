class Subscription < ApplicationRecord
  belongs_to :account
  has_many :invoices, dependent: :destroy
  has_many :subscription_coupons
  has_many :subscription_credits
  # after_create :set_stripe_customer_id

  def set_stripe_customer_id
    client = Stripe::StripeClient.new(ENV["STRIPE_KEY"])
    customer = client.v1.customers.create({
      name: account.name,
      email: account.billing_contact
    })
    self.stripe_customer_id = customer.id
    save
  end

  def plan
    # return nil if plan_id.nil?

    @plan ||= Plan.find(plan_id)
  end

  def usage_rate
    0
    # usage.to_f / plan.credits
  end

  def next_billing_amount
    return plan.price_annual if self.yearly
    plan.price
  end
end
