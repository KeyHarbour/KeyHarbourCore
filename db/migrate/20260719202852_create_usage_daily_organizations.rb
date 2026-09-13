class CreateUsageDailyOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :usage_daily_organizations do |t|
      t.references :organization, null: false, foreign_key: true
      t.date :day
      t.integer :units
      t.integer :credits
      t.string :service_name

      t.timestamps
    end
    add_index :usage_daily_organizations, :service_name
    add_index :usage_daily_organizations, :day
    add_index :usage_daily_organizations, [ :service_name, :day, :organization_id ], unique: true
  end
end
