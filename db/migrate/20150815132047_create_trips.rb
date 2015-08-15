class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.integer :start_location_id
      t.integer :end_location_id

      t.timestamps null: false
    end
  end
end
