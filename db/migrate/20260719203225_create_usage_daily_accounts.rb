class CreateUsageDailyAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :usage_daily_accounts do |t|
      t.references :account, null: false, foreign_key: true
      t.date :day
      t.integer :units
      t.integer :credits
      t.string :service_name

      t.timestamps
    end
    add_index :usage_daily_accounts, :service_name
    add_index :usage_daily_accounts, :day
    add_index :usage_daily_accounts, [ :service_name, :day, :account_id ], unique: true
  end
end
