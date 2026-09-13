class CreateProcessedDates < ActiveRecord::Migration[8.1]
  def change
    create_table :processed_dates do |t|
      t.date :day
      t.datetime :start_at
      t.datetime :end_at
      t.boolean :pushed, default: false

      t.timestamps
    end
    add_index :processed_dates, :day
  end
end
