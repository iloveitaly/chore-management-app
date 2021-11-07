class CreateChildrenAgain < ActiveRecord::Migration[5.0]
  def change
    create_table :children do |t|
      t.string :name
      t.string :email
      t.references :family, foreign_key: true

      t.timestamps
    end

    add_reference :accounts, :child, index: true
    add_foreign_key :accounts, :children
  end
end
