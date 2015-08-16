class CreateAccounts < ActiveRecord::Migration
  def change
    create_table :accounts do |t|
      t.decimal :balance, default: 0.00
      t.belongs_to :user, index: true

      t.timestamps null: false
    end
  end
end
