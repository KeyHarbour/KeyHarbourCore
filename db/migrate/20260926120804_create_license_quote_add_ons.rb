class CreateLicenseQuoteAddOns < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quote_add_ons do |t|
      t.references :add_on, null: false, foreign_key: { to_table: :license_add_ons }
      t.references :quote_instance, null: false, foreign_key: { to_table: :license_quote_instances }
      t.decimal :amount, precision: 10, scale: 2
      t.integer :seats
      t.boolean :unused, default: false

      t.timestamps
    end
  end
end
