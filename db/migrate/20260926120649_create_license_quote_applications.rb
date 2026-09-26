class CreateLicenseQuoteApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quote_applications do |t|
      t.references :license_application, null: false, foreign_key: true
      t.references :license_quote, null: false, foreign_key: true
      t.decimal :amount

      t.timestamps
    end
  end
end
