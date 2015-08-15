class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :type
      t.integer :paymentID

      t.timestamps null: false
    end
  end
end
