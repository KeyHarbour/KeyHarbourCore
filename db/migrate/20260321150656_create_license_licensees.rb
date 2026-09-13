class CreateLicenseLicensees < ActiveRecord::Migration[8.1]
  def change
    create_table :license_licensees do |t|
      t.references :instance, null: false, foreign_key: { to_table: :license_instances }
      t.string :uuid, null: false
      t.integer :status, default: 0, null: false
      t.string :revision
      t.date :last_access

      t.timestamps
    end
  end
end
