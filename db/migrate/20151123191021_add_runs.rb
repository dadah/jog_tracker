class AddRuns < ActiveRecord::Migration
  def change

    create_table :runs do |t|
      t.references :user
      t.datetime :run_date, null: false
      t.integer :run_time, null: false
      t.integer :distance, null: false

      t.timestamps
    end

  end
end
