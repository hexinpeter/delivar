class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.string :type
      t.integer :paymentID
      t.belongs_to :account, index: true

      t.timestamps null: false
    end
  end
end
