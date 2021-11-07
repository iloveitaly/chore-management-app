class Api::V1::CurrenciesController < Api::V1::Base
  # TODO re-enable only unauth's child login is tied to some sort of auth
  # before_action :authenticate_user!

  def index
    render json: Currency.all
  end
end
