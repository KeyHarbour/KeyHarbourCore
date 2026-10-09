class CreateLicenseQuotes < ActiveRecord::Migration[8.1]
  def change
    create_table :license_quotes do |t|
      t.references :application, null: false, foreign_key: { to_table: :license_applications }
      t.references :provider, null: false, foreign_key: { to_table: :license_providers }
      t.string :uuid
      t.date :available_on
      t.date :available_until
      t.date :approved_at 
      t.string :status

      t.timestamps
    end
  end
end
