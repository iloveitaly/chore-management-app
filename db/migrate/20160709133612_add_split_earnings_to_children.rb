class AddSplitEarningsToChildren < ActiveRecord::Migration[5.0]
  def change
    add_column :children, :split_earnings, :boolean, default: false
  end
end
