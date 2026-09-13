class CreateInstanceCredits < ActiveRecord::Migration[8.1]
  def change
    create_table :instance_credits do |t|
      t.date :day
      t.integer :credits
      t.string :service_name

      t.timestamps
    end
    add_index :instance_credits, :service_name
    add_index :instance_credits, :day
    add_index :instance_credits, [ :service_name, :day ], unique: true
  end
end
