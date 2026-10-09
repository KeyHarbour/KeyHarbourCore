class ChangeOrganizationToAccount < ActiveRecord::Migration[8.1]
  def change
    add_reference :license_applications, :account, foreign_key: true
    remove_reference :license_applications, :organization, foreign_key: true
    add_reference :license_team_members, :account, foreign_key: true
    remove_reference :license_team_members, :organization, foreign_key: true
  end
end
