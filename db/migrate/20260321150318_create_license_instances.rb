class CreateLicenseInstances < ActiveRecord::Migration[8.1]
  def change
    create_table :license_instances do |t|
      t.references :application, null: false, foreign_key: { to_table: :license_applications }
      t.string  :name
      t.string  :uuid
      t.string  :short_name
      t.string  :owner
      t.date    :renewal_date
      t.integer :licencess_allowed
      t.text    :data
      t.integer :seats
      t.decimal :unit_cost, precision: 10, scale: 2
      t.integer :status, default: 0, null: false
      t.integer :alert_renewal_2, default: 30
      t.integer :alert_renewal_1, default: 90
      t.decimal :alert_seats_2, precision: 10, scale: 2, default: 0.95
      t.decimal :alert_seats_1, precision: 10, scale: 2, default: 0.85

      t.timestamps
    end
    add_index :license_instances, [ :uuid, :application_id ], unique: true
  end
end
