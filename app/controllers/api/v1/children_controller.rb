class Api::V1::ChildrenController < Api::V1::Base
  # TODO move to API helpers
  rescue_from ActionController::ParameterMissing do |e|
    render json: { error: e.message }, status: :unprocessable_entity
  end

  # TODO remove `except` when unauth'd
  before_action :authenticate_user!, except: [:show]

  def index
    render json: current_user.family.children
  end

  def show
    # TODO scope this method the current family
    render json: Child.find(params[:id])
  end

  def setup
    # TODO scope this method the current family
    child = Child.find(params[:child_id])

    # set the child email
    if child_setup_params[:email].present?
      child.update(email: child_setup_params[:email])
    end

    # TODO we should check here in the future if for some reason the child has
    #      multiple accounts
    account = child.accounts.first

    # set the child's initial account currency type
    if child_setup_params[:currency_id].present?
      account.update(currency_id: child_setup_params[:currency_id])
    end

    # create the initial balance transaction
    if child_setup_params[:balance].present?
      balance = sanitize_number(child_setup_params[:balance])
      balance = normalize_transaction_amount(account.currency, balance)

      Transaction.create!(
        account: account,
        description: "Starting Balance",
        payee: current_user.name,
        amount: balance,
      )
    end

    # find the next child that needs to be set up based on default ordering
    next_child = current_user.
      family.
      children.
      where('created_at < ?', child.created_at).
      first

    render json: { next_child: next_child.try(:id) }
  end

  def create
    child = Child.new(child_params)
    child.family = current_user.family

    # normalize email input for devise login oauth match
    if child_params[:email].present?
      child.email = child_params[:email].strip.downcase
    end

    if child.save
      render json: child, status: :created
    else
      render json: child.errors, status: :unprocessable_entity
    end
  end

  def update
    child = Child.find(params[:id])
    child.update_attributes(child_params)

    # TODO there's got to be an easier way to clean this up
    if child.email_enabled
      child.update_email_schedule(
        child_email_frequency_params['email_frequency'],
        child_email_frequency_params['email_frequency'] == 'weekly' ? child_email_frequency_params['email_week_day'] : child_email_frequency_params['email_month_day']
      )
    end

    if child.split_earnings
      child_split_earnings_schedule.each do |schedule|
        account = Account.find(schedule[:account_id])
        account.update(split_percentage: schedule[:split_percentage])
      end
    end

    if child.save
      head :ok
    else
      render json: child.errors, status: :unprocessable_entity
    end
  end

  private

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

    def child_split_earnings_schedule
      params.require(:split_earnings_schedule)
    end

    def child_params
      params.require(:child).permit(
        :name,
        :email,
        :email_enabled,
        :split_earnings
      )
    end

    def child_email_frequency_params
      params.permit(
        :email_frequency,
        :email_week_day,
        :email_month_day
      )
    end

    def child_setup_params
      params.permit(
        :balance,
        :email,
        :currency_id
      )
    end
end
