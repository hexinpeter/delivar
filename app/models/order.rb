class Order < ActiveRecord::Base
	has_many :items
	belongs_to :user
	has_one :trip
end
