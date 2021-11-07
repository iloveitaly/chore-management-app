class AddZeroDecimalFlagToCurrency < ActiveRecord::Migration[5.0]
  def change
    add_column :currencies, :zero_decimal, :boolean, default: false
  end
end
