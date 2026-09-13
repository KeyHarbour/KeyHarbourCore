class CreateInventoryInstanceAttr < ActiveRecord::Migration[8.1]
  def change
    create_table :inventory_instance_attrs do |t|
      t.references :model_category_attr, null: false, foreign_key: { to_table: :inventory_model_category_attrs }
      t.references :instance, null: false, foreign_key: { to_table: :inventory_instances }
      t.string :name
      t.string :value

      t.timestamps
    end
  end
end
