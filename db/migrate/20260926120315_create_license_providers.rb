class CreateLicenseProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :license_providers do |t|
      t.references :account, null: false, foreign_key: true
      t.string :name
      t.string :uuid

      t.timestamps
    end
  end
end
