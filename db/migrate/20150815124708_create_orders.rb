class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.string :status
      t.integer :tips
      t.float :estimated_total
      t.float :actual_total
      t.float :refund

      t.timestamps null: false
    end
  end
end
