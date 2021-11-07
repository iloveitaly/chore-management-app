class Api::V1::FamiliesController < Api::V1::Base
  before_action :authenticate_user!

  def show
    render json: Family.find(params[:id])
  end

  # NOTE this action is for setting up all of the children in your account
  def setup
    family = current_user.family

    family.name = family_params[:name]

    if !family.save
      render json: family.errors, status: :unprocessable_entity
    end

    family_params["children"].reverse.each do |child|
      next if child[:name].blank?

      child = Child.create!(
        name: child[:name],
        family: family
      )

      account = Account.create!(
        currency: Currency.account_default,
        child: child,
        # TODO family should proxy through child
        family: family,
        name: "#{child.name}'s Account"
      )
    end

    render json: { setup_child: family.children.first.id }
  end

  protected

    def family_params
      params.require(:family).permit(
        :name,
        children: [ :name ],
      )
    end

end
