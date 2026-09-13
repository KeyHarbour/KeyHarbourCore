class CreateSubscriptionCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_coupons do |t|
      t.references :subscription, null: false, foreign_key: true
      t.references :coupon, null: false, foreign_key: true
      t.date :used

      t.timestamps
    end
  end
end
