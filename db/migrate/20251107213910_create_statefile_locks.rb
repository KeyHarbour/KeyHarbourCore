class CreateStatefileLocks < ActiveRecord::Migration[8.0]
  def change
    create_table :statefile_locks do |t|
      t.references :workspace, null: false, foreign_key: true
      t.datetime :locked_at
      t.string  :uuid
      t.string  :operation
      t.string  :info
      t.string  :who
      t.string  :version
      t.string  :path

      t.timestamps
    end
  end
end
