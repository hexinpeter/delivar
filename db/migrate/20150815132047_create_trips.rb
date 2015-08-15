class CreateTrips < ActiveRecord::Migration
  def change
    create_table :trips do |t|
      t.integer :start_location_id
      t.integer :end_location_id
      t.belongs_to :order, index: true
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
