class CreateSubscriptionCredits < ActiveRecord::Migration[8.1]
  def change
    create_table :subscription_credits do |t|
      t.references :subscription, null: false, foreign_key: true
      t.string :uuid
      t.date :month
      t.integer :credits
      t.integer :credit_balance
      t.string :event
      t.integer :order

      t.timestamps
    end
  end
end
