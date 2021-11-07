class AddInterestRateToChild < ActiveRecord::Migration[5.0]
  def change
    add_column :children, :interest_rate, :integer, default: nil
  end
end
