class CreateUsageMonthlyAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :usage_monthly_accounts do |t|
      t.references :account, null: false, foreign_key: true
      t.date :month
      t.integer :units
      t.integer :credits

      t.timestamps
    end
    add_index :usage_monthly_accounts, :month
    add_index :usage_monthly_accounts, [ :month, :account_id ], unique: true
  end
end
