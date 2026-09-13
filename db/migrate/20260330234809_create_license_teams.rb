class CreateLicenseTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :license_team_members do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :uuid, null: false
      t.references :manager, null: true, foreign_key: { to_table: :license_team_members }, index: true
      t.string :role
      t.string :revision

      t.timestamps
    end
  end
end
