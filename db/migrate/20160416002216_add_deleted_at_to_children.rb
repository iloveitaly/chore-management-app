class AddDeletedAtToChildren < ActiveRecord::Migration[5.0]
  def change
    add_column :children, :deleted_at, :datetime, default: nil
  end
end
