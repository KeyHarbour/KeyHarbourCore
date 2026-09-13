class CreateCoupons < ActiveRecord::Migration[8.1]
  def change
    create_table :coupons do |t|
      t.string :name
      t.date :valid_at
      t.date :valid_until
      t.string :uuid
      t.integer :amount_off
      t.decimal :percent_off
      t.boolean :duration_limited, default: true
      t.integer :duration_in_month, default: 1
      t.integer :redeem_limit, default: 1
      t.integer :status, default: 0, null: false
      t.string :stripe_id
      t.string :plan_id
      t.timestamps
    end
  end
end
