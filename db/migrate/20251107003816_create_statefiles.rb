class CreateStatefiles < ActiveRecord::Migration[8.0]
  def change
    create_table :statefiles do |t|
      t.references :workspace, null: false, foreign_key: true
      t.references :environment, null: false, foreign_key: true
      t.string :uuid
      t.text :content, default: ""
      t.datetime :published_at

      t.timestamps
    end
    add_index :statefiles, :uuid
  end
end
