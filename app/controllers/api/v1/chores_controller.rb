class Api::V1::ChoresController < Api::V1::Base
  include TransactionProcessing

  before_action :authenticate_user!

  def index
    render json: current_family.
      chores.
      incomplete
  end

  def show
    chore = Chore.find(params[:id])

    render json: chore
  end

  def create
    chore = Chore.new
    chore.family = current_family

    chore.update_attributes(chore_params)

    if chore.save
      render json: chore, status: :created
    else
      render json: chore.errors, status: :unprocessable_entity
    end

    head :ok
  end

  def update
    chore = Chore.find(params[:id])
    chore.update_attributes(chore_params)

    if chore.save
      head :created
    else
      render json: chore.errors, status: :unprocessable_entity
    end
  end

  def destroy
    chore = Chore.find(params[:id])
    chore.update_attribute(:deleted_at, DateTime.now)

    head :ok
  end

  def pay
    chore = Chore.find(params[:chore_id])
    account = Account.find(params[:account_id])

    amount = sanitize_number(payment_params[:value])
    amount = normalize_transaction_amount(account.currency, amount)

    payment = Transaction.new(
      amount: amount,
      account: account,
      description: chore.name,
      payor: current_user.name
    )

    if !payment.save
      render json: payment.errors, status: :unprocessable_entity
      return
    end

    chore.paid_on = DateTime.now
    chore.status = 'paid'

    if chore.save
      if chore.recurring?
        new_chore = chore.dup
        new_chore.status = 'open'
        new_chore.paid_on = nil
        new_chore.save!

        render json: { new_chore_id: new_chore.id }
        return
      end

      head :ok
    else
      render json: chore.errors, status: :unprocessable_entity
    end
  end

  protected

    def chore_params
      params.require(:chore).permit(
        :name,
        :description,
        # :due_date,
        :child_id,
        :value,
        :recurring
      )
    end

    def payment_params
      params.require(:chore).permit(
        :value,
        :account_id
      )
    end

end
