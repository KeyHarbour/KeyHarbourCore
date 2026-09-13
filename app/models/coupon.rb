class Coupon < ApplicationRecord
  include Archivable
  VALID_SLUG_REGEX = /\A[a-z0-9-]+\z/
  after_create :create_or_update_coupon
  # before_destroy :delete_coupon
  validates :name, presence: true, uniqueness: true
  has_many :subscription_coupons
  has_many :coupon_plans, dependent: :destroy
  # before_update :block_update

  validates :uuid, 
            presence: true, 
            format: { 
              with: VALID_SLUG_REGEX, 
              message: "doit contenir uniquement des lettres minuscules, des chiffres et des tirets" 
            }  

  scope :actifs, -> {
    left_joins(:subscription_coupons)
      .where("valid_at <= :now AND valid_until >= :now", now: Time.current)
      .group(:id)
      .having("COUNT(subscription_coupons.id) < coupons.redeem_limit")
  }

  def plan
    @plan ||= Plan.find(plan_id)
  end
  # def plan_ids
  #   coupon_plans.pluck(:plan_id)
  # end

  # def plan_ids=(ids)
  #   nettoye_ids = Array(ids).reject(&:blank?)
  #   self.coupon_plans = nettoye_ids.map { |id| coupon_plans.build(plan_id: id) }
  # end

  def client
    @client ||= Stripe::StripeClient.new(Stripe.api_key)
  end

  def readonly?
    persisted?
  end

  def delete_coupon
    client.v1.coupons.delete(stripe_id)
    
    if subscription_coupons.count == 0
      coupon_plans.delete_all
      Coupon.delete(self.id)
    end
  end

  def create_or_update_coupon
    if stripe_id?
      # update coupon
    else
      create_coupon
    end
  end

  def create_coupon
    data = {
      currency: 'CAD',
      name: name,
      max_redemptions: redeem_limit,
      redeem_by: valid_until.to_time.to_i
    }

    if duration_limited == false
      data[:duration] = 'forever'
    else
      data[:duration] = 'repeating'
      data[:duration_in_months] = duration_in_month
    end

    if amount_off && amount_off > 0
      data[:amount_off] = amount_off.to_i * 100
    else
      data[:percent_off] = percent_off
    end
    logger.debug data
    coupon = client.v1.coupons.create(data)

    Coupon.where(id: self.id).update_all(stripe_id: coupon.id)
  end
end
