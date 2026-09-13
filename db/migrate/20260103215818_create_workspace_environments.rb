class CreateWorkspaceEnvironments < ActiveRecord::Migration[8.1]
  def change
    create_table :workspace_environments do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true
      t.integer :resources, default: 0
      t.integer :lines, default: 0
      t.integer :size, default: 0
      t.decimal :cost, precision: 10, scale: 6, default: "0.0"
      t.timestamps
    end
  end
end
