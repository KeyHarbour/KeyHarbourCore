class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :address1
      t.string :address2
      t.string :zip
      t.string :city
      t.string :country_code
      t.string :province_code
      t.string :billing_contact
      t.integer :status, default: 0, null: false
      t.string :uuid
      t.string :plan, default: "free", null: false

      t.timestamps
    end
    add_index :accounts, :status
    add_reference :organizations, :account, null: false, index: true, foreign_key: true
    add_reference :teams, :account, null: false, index: true, foreign_key: true
  end
end
