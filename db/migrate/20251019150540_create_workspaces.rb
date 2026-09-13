class CreateWorkspaces < ActiveRecord::Migration[8.0]
  def change
    create_table :workspaces do |t|
      t.references :project, null: false, foreign_key: true
      t.string :name
      t.string :uuid
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :workspaces, :uuid
    add_index :workspaces, :status
  end
end
