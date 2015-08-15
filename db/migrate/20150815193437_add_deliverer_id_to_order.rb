class AddDelivererIdToOrder < ActiveRecord::Migration
  def change
    add_column :orders, :deliverer_id, :integer
  end
end
