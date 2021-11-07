class AddRecurringToChores < ActiveRecord::Migration[5.0]
  def change
    add_column :chores, :recurring, :boolean, default: false
  end
end
