class Trip < ActiveRecord::Base
	belongs_to :order
	belongs_to :user

  def distance(trip)
    start_loc1 = Location.find(start_location_id)
    end_loc1 = Location.find(end_location_id)

    start_loc2 = Location.find(trip.start_location_id)
    end_loc2 = Location.find(trip.end_location_id)

    Location.distance(start_loc1, start_loc2) + Location.distance(end_loc1, end_loc2)
  end
end
