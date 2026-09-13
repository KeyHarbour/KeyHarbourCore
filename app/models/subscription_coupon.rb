class SubscriptionCoupon < ApplicationRecord
  belongs_to :subscription
  belongs_to :coupon
  attr_accessor :coupon_code
  # after_create :validate_free
  #
  # def validate_free
  #   if coupon.percent_off == 100
  #     # free_api_call = coupon.plan.credits * coupon.duration_in_month
  #     # Current.account.account_histories.create!(
  #     #   is_credit: true,
  #     #   day: DateTime.now.to_date,
  #     #   uuid: coupon.uuid,
  #     #   queries: free_api_call
  #     # )
  #     # account_monthly = Current.account.account_monthlies.current
  #     # account_monthly.update!(queries_ordered: account_monthly.queries_ordered + free_api_call)
  #     # Notification.create!(
  #     #   recipient: Current.user,
  #     #   message: "#{coupon.duration_in_month} mois gratuit vous été ajoutez soit #{free_api_call} appels d'API gratuits",
  #     #   title: "Merci"
  #     # )
  #     # self.update!(used: true)
  #   end
  # end
end
