class SplitIncome
  include Interactor

  def call
    amount = context.transaction_params[:amount]

    context.child.accounts.where(currency: context.child.default_currency).each do |account|
      next if account.split_percentage <= 0

      split_amount = amount.to_f * (account.split_percentage / 100.0)

      # TODO this shold be moved to a helper
      if !account.currency.zero_decimal
        split_amount *= 100.0
      end

      transaction = Transaction.new(context.transaction_params)
      transaction.description = "#{transaction.description} (#{account.split_percentage}%)"
      transaction.amount = split_amount
      transaction.account = account
      transaction.save!
    end
  end
end
