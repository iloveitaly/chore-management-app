class AddDeletedAtToChores < ActiveRecord::Migration[5.0]
  def change
    add_column :chores, :deleted_at, :datetime, default: nil
  end
end
