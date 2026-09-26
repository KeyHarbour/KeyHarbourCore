class AddTierToLicenseInstance < ActiveRecord::Migration[8.1]
  def change
    add_column :license_instances, :tier, :string
  end
end
