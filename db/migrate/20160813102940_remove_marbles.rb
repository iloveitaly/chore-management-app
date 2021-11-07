class RemoveMarbles < ActiveRecord::Migration[5.0]
  def change
    marbles = Currency.find_by(name: 'Marbles')
    replacement_currency = Currency.find_by(name: 'Time')

    Account.where(currency_id: marbles.id).each do |account|
      account.currency = replacement_currency
      account.save!
    end

    marbles.delete
  end
end
