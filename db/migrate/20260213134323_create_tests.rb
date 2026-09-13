class CreateTests < ActiveRecord::Migration[8.1]
  def change
    create_table :tests do |t|
      t.string :data

      t.timestamps
    end
  end
end
