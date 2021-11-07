class AddAccountReportConfigurationToChild < ActiveRecord::Migration[5.0]
  def change
    add_column :children, :email_enabled, :boolean, default: true
    add_column :children, :account_update_schedule, :text, default: nil

    reversible do |direction|
      direction.up do
        Child.reset_column_information

        Child.all.each do |child|
          child.update_email_schedule('weekly', 1)
          child.save
        end
      end
    end
  end
end
