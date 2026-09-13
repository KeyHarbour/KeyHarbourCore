class CreateInventoryModelCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_model_categories do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :model_family, null: false, foreign_key: { to_table: :inventory_model_families }
      t.string :name
      t.string :resource_type
      t.boolean :active, default: true

      t.timestamps
    end
  end
end
