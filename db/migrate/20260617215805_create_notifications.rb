class CreateNotifications < ActiveRecord::Migration[8.1]
  def change
    create_table :notifications do |t|
      t.references :recipient, polymorphic: true, null: false
      t.string :title
      t.string :message
      t.datetime :read_at

      t.timestamps
    end
  end
end
