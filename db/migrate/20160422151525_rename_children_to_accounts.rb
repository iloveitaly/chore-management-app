class RenameChildrenToAccounts < ActiveRecord::Migration[5.0]
  def change
    rename_table :children, :accounts
    rename_column :transactions, :child_id, :account_id
  end
end
