class Invoice < ApplicationRecord
  belongs_to :subscription
  validates :stripe_invoice_id, presence: true, uniqueness: true
  # after_create :create_monthly

  def account
    subscription.account
  end

  def tps
    (amount * 0.05).round(2)
  end

  def tvq
    (amount * 0.09975).round(2)
  end

  def total
    (amount + tps + tvq).round(2)
  end

  # def create_monthly
  #   account_monthly = subscription.account.account_monthlies.current
  #   account_monthly.update!(queries_ordered: account_monthly.queries_ordered + subscription.plan.credits)
  #   subscription.account.account_histories.create!(
  #     is_credit: true,
  #     day: DateTime.now.to_date,
  #     uuid: self.ref,
  #     queries: subscription.plan.credits
  #   )
  # end
end
