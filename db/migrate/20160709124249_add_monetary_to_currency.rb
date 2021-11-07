class AddMonetaryToCurrency < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :monetary, :boolean, default: false
  end
end
