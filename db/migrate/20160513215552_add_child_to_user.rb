class AddChildToUser < ActiveRecord::Migration[5.0]
  def change
    add_reference :users, :child, foreign_key: true
  end
end
