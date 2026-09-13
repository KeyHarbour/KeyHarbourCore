class CreateInvoices < ActiveRecord::Migration[8.1]
  def change
    create_table :invoices do |t|
      t.references :subscription, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2
      t.date :date
      t.date :period_end
      t.date :period_start
      t.string :stripe_invoice_id
      t.string :status
      t.string :ref

      t.timestamps
    end
  end
end
