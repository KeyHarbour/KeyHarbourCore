class CreateTrustAssets < ActiveRecord::Migration[8.1]
  def change
    create_table :trust_assets do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true
      t.string :name
      t.datetime :expires_at
      t.string :issuer
      t.integer :format
      t.string :consumer
      t.text :description
      t.integer :reminder_days, default: 7

      t.timestamps
    end
  end
end
