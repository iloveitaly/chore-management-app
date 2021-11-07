class CreateChores < ActiveRecord::Migration[5.0]
  def change
    create_table :chores do |t|
      t.string :name
      t.datetime :due_date
      t.datetime :paid_on
      t.text :description
      t.integer :value
      t.references :child, foreign_key: true
      t.references :family, foreign_key: true
      t.integer :parent_id

      t.timestamps
    end

    add_index :chores, :parent_id
  end
end
