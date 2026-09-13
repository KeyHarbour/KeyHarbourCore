class CreateTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :tokens do |t|
      t.string :name
      t.references :scopable, polymorphic: true, null: false
      t.references :environment, null: true, foreign_key: true
      t.datetime :expiration
      t.datetime :last_used_at

      t.timestamps
    end
  end
end
