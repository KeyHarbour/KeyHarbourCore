class CreateKeyValueStores < ActiveRecord::Migration[8.1]
  def change
    create_table :key_value_stores do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true
      t.string :key
      t.text :value
      t.boolean :one_time_only, default: false
      t.boolean :private, default: false
      t.datetime :expires_at

      t.timestamps
    end
    add_index :key_value_stores, :key
    add_index :key_value_stores, :expires_at
  end
end
