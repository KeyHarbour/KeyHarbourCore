class CreateAccountUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :account_users do |t|
      t.references :user, null: false, foreign_key: true
      t.references :account, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true

      t.timestamps
    end
    # User.find_each do |user|
    #   AccountUser.create(user: user, account: Account.first)
    # end
  end
end
