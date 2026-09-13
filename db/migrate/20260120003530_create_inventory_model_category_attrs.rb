class CreateInventoryModelCategoryAttrs < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_model_category_attrs do |t|
      t.references :model_category, null: false, foreign_key: { to_table: :inventory_model_categories }
      t.string :name
      t.string :attr_name
      t.boolean :active

      t.timestamps
    end
  end
end
