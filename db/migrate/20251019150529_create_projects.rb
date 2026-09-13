class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :name
      t.string :uuid
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :projects, :uuid
    add_index :projects, :status
  end
end
