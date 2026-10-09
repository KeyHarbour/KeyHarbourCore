class CreateLicenseQuoteInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quote_instances do |t|
      t.references :instance, null: false, foreign_key: { to_table: :license_instances }
      t.references :quote_application, null: false, foreign_key: { to_table: :license_quote_applications }
      t.decimal :amount, precision: 10, scale: 2
      t.integer :seats
      t.boolean :unused, default: false

      t.timestamps
    end
  end
end
