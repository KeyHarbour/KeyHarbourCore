class Invoice < ApplicationRecord
  belongs_to :subscription
  validates :stripe_invoice_id, presence: true, uniqueness: true

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
end
