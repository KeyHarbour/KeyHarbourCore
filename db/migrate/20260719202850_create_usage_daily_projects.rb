class CreateUsageDailyProjects < ActiveRecord::Migration[8.1]
  def change
    create_table :usage_daily_projects do |t|
      t.references :project, null: false, foreign_key: true
      t.date :day
      t.integer :units
      t.integer :credits
      t.string :service_name

      t.timestamps
    end
    add_index :usage_daily_projects, :service_name
    add_index :usage_daily_projects, :day
    add_index :usage_daily_projects, [ :service_name, :day, :project_id ], unique: true
  end
end
