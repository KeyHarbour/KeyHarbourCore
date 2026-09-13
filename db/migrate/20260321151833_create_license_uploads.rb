class CreateLicenseUploads < ActiveRecord::Migration[8.1]
  def change
    create_table :license_uploads do |t|
      t.references :instance, null: false, foreign_key: { to_table: :license_instances }
      t.integer :status

      t.timestamps
    end
  end
end
