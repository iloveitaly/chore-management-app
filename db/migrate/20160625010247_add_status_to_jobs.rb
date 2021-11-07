class AddStatusToJobs < ActiveRecord::Migration[5.0]
  def change
    add_column :chores, :status, :string, default: 'open' 
  end
end
