class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name
      t.string :uuid
      t.string :description
      t.integer :source, default: 0, null: false

      t.timestamps
    end
  end
end
