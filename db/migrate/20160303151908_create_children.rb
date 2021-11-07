class CreateChildren < ActiveRecord::Migration[5.0]
  def change
    create_table :children do |t|
      t.string :name
      t.references :currency, foreign_key: true
      t.references :family, foreign_key: true

      t.timestamps
    end
  end
end
