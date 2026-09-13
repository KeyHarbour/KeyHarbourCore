class CreateUsageDailyWorkspaces < ActiveRecord::Migration[8.1]
  def change
    create_table :usage_daily_workspaces do |t|
      t.references :workspace, null: false, foreign_key: true
      t.date :day
      t.integer :units
      t.integer :credits
      t.string :service_name

      t.timestamps
    end
    add_index :usage_daily_workspaces, :service_name
    add_index :usage_daily_workspaces, :day
    add_index :usage_daily_workspaces, [ :service_name, :day, :workspace_id ], unique: true
  end
end
