class CreateLicenseQuoteApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quote_applications do |t|
      t.references :application, null: false, foreign_key: { to_table: :license_applications }
      t.references :quote, null: false, foreign_key: { to_table: :license_quotes }
      t.decimal :amount, precision: 10, scale: 2
      t.integer :seats

      t.timestamps
    end
  end
end
