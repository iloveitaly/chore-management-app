class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.integer :amount
      t.references :child, foreign_key: true
      t.string :description
      t.string :payee
      t.string :payor

      t.timestamps
    end
  end
end
