class CreateApiQueries < ActiveRecord::Migration[8.1]
  def change
    create_table :api_queries do |t|
      t.string :serviceable_type, null: false
      t.bigint :serviceable_id, null: false
      t.string :controller, null: false
      t.string :action, null: false
      t.string :service_name
      t.integer :token
      t.datetime :date, default: -> { "CURRENT_TIMESTAMP" }, null: false
      t.timestamps
    end
    add_index :api_queries, :service_name
    add_index :api_queries, :date
  end
end
