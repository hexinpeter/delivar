class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :name
      t.string :quantity
      t.float :estimated_price
      t.float :actual_price
      t.belongs_to :order, index: true

      t.timestamps null: false
    end
  end
end
