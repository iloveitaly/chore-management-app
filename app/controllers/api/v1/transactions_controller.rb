class Api::V1::TransactionsController < Api::V1::Base
  before_action :authenticate_user!, except: [:index]

  def index
    render json: Account.find(params[:account_id]).transactions
  end

  def show
    render json: Transaction.find(params[:id])
  end

  def update
    transaction = Transaction.find(params[:id])
    transaction.update_attributes(transaction_update_params)

    translate_currency(transaction)

    if transaction.save
      head :ok
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  def create
    from_account = Account.find(params[:account_id])

    if params[:type] == 'transfer'
      destination_account = Account.find(params[:destination_account])

      if from_account.currency != destination_account.currency
        render json: 'accounts are different currencies', status: :unprocessable_entity
        return
      end

      transaction_from = Transaction.new(
        account: from_account,
        description: transaction_params[:description],
        transaction_type: 'transfer',
        payee: destination_account.name,
        amount: transaction_params[:amount],
      )

      translate_currency(transaction_from)
      transaction_from.amount *= -1

      transaction_to = Transaction.new(
        account: destination_account,
        description: transaction_params[:description],
        transaction_type: 'transfer',
        payor: from_account.name,
        amount: transaction_params[:amount]
      )

      translate_currency(transaction_to)

      # TODO should wrap in a transaction

      if transaction_from.save && transaction_to.save
        head :created
      else
        # TODO we should output transation_to errors
        render json: transaction_from.errors || transaction_to.errors, status: :unprocessable_entity
      end

      return
    end

    if params[:type] == 'income' && params[:split_income] == true
      SplitIncome.call(
        transaction_params: transaction_params,
        child: from_account.child
      )

      head :created
      return
    end

    transaction = Transaction.new(transaction_params)
    transaction.account = from_account

    translate_currency(transaction)

    if transaction.save
      head :created
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  private

    # TODO DRY this up! This is used on the children contrller as well
    def translate_currency(transaction)
      # TODO this should be handled on the client side.
      # NOTE amount is pulled from params since the number is casted to a int on transaction
      if !transaction.account.currency.zero_decimal
        transaction.amount = transaction_params[:amount].to_f * 100.0
      end
    end

    def transaction_update_params
      params.require(:transaction).permit(
        :amount,
        :description,
        :payee,
        :payor
      )
    end

    def transaction_params
      params.require(:transaction).permit(
        :type,
        :amount,
        :account_id,
        :description,
        :payee,
        :payor,
        :destination_account
      )
    end
end
