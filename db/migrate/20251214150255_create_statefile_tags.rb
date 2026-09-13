class CreateStatefileTags < ActiveRecord::Migration[8.1]
  def change
    create_table :statefile_tags do |t|
      t.references :statefile, null: false, foreign_key: true
      t.string :tag

      t.timestamps
    end
  end
end
