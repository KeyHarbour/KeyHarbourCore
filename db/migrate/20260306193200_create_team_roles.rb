class CreateTeamRoles < ActiveRecord::Migration[8.1]
  def change
    create_table :team_roles do |t|
      t.references :team, null: false, foreign_key: true
      t.references :resource, polymorphic: true, null: false
      t.integer :role

      t.timestamps
    end
  end
end
