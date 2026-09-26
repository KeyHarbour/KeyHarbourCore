class CreateLicenseAddOns < ActiveRecord::Migration[8.1]
  def change
    create_table :license_add_ons do |t|
      t.references :license_instance, null: false, foreign_key: true
      t.string :name
      t.string :uuid
      t.text :description
      t.boolean :active, default: true
      t.decimal :unit_cost, precision: 10, scale: 4

      t.timestamps
    end
  end
end
