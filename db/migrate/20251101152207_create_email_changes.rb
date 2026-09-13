class CreateEmailChanges < ActiveRecord::Migration[8.0]
  def change
    create_table :email_changes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :from
      t.string :to
      t.datetime :confirmed_at

      t.timestamps
    end
  end
end
