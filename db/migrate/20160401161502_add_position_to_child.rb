class AddPositionToChild < ActiveRecord::Migration[5.0]
  def change
    add_column :children, :position, :integer

    reversible do |direction|
      direction.up do
        Child.reset_column_information

        Family.all.each do |family|
          family.children.order(:created_at).each_with_index do |child, index|
            child.update_column :position, index
          end
        end
      end
    end
  end
end
