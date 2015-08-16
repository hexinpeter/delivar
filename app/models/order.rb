class Order < ActiveRecord::Base
	has_many :items
	belongs_to :user
  belongs_to :deliverer, class_name: 'User', foreign_key: 'deliverer_id'
	has_one :trip

  scope :unassigned, -> { where(status: 'unassigned') }

end
