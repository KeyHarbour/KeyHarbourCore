class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :email_address, null: false
      t.string :password_digest, null: false
      t.boolean :email_verified, default: false
      t.string :prefered_language, default: "en"
      t.integer :global_role, default: 254
      t.string :uid
      t.string :provider
      t.string :name
      t.string :image
      t.boolean :password_change_required, default: false
      t.datetime :last_access_at
      t.timestamps
    end
    add_index :users, :email_address, unique: true
    add_index :users, [ :uid, :provider ], unique: true
  end
end
