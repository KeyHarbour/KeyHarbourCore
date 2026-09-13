class CreateActionLogs < ActiveRecord::Migration[8.1]
  def change
    create_table :action_logs do |t|
      t.bigint :user_id
      t.bigint :organization_id
      t.string :controller
      t.string :action
      t.bigint :action_id
      t.string :method_type

      t.timestamps
    end
  end
end
