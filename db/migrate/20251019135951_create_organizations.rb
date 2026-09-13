class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.string :uuid
      t.text :description
      t.integer :status, default: 0, null: false

      t.timestamps
    end
    add_index :organizations, :uuid
    add_index :organizations, :status
  end
end
