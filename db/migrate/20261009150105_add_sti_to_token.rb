class AddStiToToken < ActiveRecord::Migration[8.1]
  def change
    add_column :tokens, :type, :string
    add_index :tokens, :type
  end
end
