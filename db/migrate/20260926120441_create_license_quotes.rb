class CreateLicenseQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quotes do |t|
      t.references :license_application, null: false, foreign_key: true
      t.references :license_provider, null: false, foreign_key: true
      t.string :uuid
      t.date :available_on
      t.date :available_until
      t.date :approved_at 
      t.integer :status

      t.timestamps
    end
  end
end
