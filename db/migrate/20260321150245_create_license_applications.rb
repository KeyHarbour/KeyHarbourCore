class CreateLicenseApplications < ActiveRecord::Migration[8.1]
  def change
    create_table :license_applications do |t|
      t.references :organization, null: false, foreign_key: true
      t.string  :name
      t.string  :short_name
      t.string  :owner
      t.date    :renewal_date
      t.text    :data
      t.string  :vendor
      t.string  :tier
      t.string  :uuid
      t.integer  :seats
      t.integer  :licencess_allowed
      t.decimal :unit_cost, precision: 10, scale: 2
      t.integer :status, default: 0, null: false
      t.integer :alert_renewal_2, default: 30
      t.integer :alert_renewal_1, default: 90
      t.decimal :alert_seats_2, precision: 10, scale: 2, default: 0.95
      t.decimal :alert_seats_1, precision: 10, scale: 2, default: 0.85

      t.timestamps
    end
    add_index :license_applications, [ :uuid, :organization_id ], unique: true
  end
end
