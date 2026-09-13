class CreateSubscriptions < ActiveRecord::Migration[8.1]
  def change
    create_table :subscriptions do |t|
      t.references :account, null: false, foreign_key: true
      t.string :stripe_customer_id
      t.string :plan_id
      t.datetime :current_period_end, null: false, default: -> { "NOW() + INTERVAL '1 month'" }
      t.datetime :current_period_start, default: -> { "NOW()" }
      t.boolean :active, default: true
      t.boolean :yearly, default: false

      t.timestamps
    end
  end
end
