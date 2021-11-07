module TransactionProcessing
  extend ActiveSupport::Concern

  def normalize_transaction_amount(currency, number)
    if !currency.zero_decimal
      number.to_f * 100.0
    else
      number
    end
  end

  def sanitize_number(number_input)
    number_input.to_s.gsub(/[^0-9\.-]+/, '')
  end

end
