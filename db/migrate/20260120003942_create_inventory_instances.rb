class CreateInventoryInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_instances do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true
      t.references :model_category, null: false, foreign_key: { to_table: :inventory_model_categories }
      t.string :name
      t.string :uuid
      t.integer :status

      t.timestamps
    end
  end
end
