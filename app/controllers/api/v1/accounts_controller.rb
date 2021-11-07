class Api::V1::AccountsController < Api::V1::Base
  before_action :authenticate_user!, except: [:show]

  def index
    render json: current_user.accounts
  end

  def show
    render json: Account.find(params[:id])
  end

  def create
    account = Account.new(account_params)
    account.family = current_user.family

    # set default currency if none was provided
    if account.currency.blank?
      account.currency = Currency.find_by(name: 'USD')
    end

    if account.save
      head :created
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  def update
    account = Account.find(params[:id])
    account.update_attributes(account_params)

    if account.save
      head :created
    else
      render json: account.errors, status: :unprocessable_entity
    end
  end

  def destroy
    account = Account.find(params[:id])
    account.update_attribute(:deleted_at, DateTime.now)

    head :ok
  end

  private

    def account_params
      params.require(:account).permit(
        :name,
        :currency_id,
        :interest_rate,
        :position,
        :child_id
      )
    end
end
