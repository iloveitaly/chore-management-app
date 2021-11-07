class AddSplitPercentageToAccount < ActiveRecord::Migration[5.0]
  def change
    add_column :accounts, :split_percentage, :integer, default: 0
  end
end
