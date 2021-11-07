class Api::V1::ChildChoresController < Api::V1::Base
  # TODO we need to auth at some point
  # before_action :authenticate_user!

  def index
    render json: current_child
      .chores
      .where("status != 'paid'")
  end

  def unclaimed
    render json: current_child.
      family.
      chores.
      where(child_id: nil)
  end

  def show
    render json: Chore.find(params[:id])
  end

  def claim
    chore = Chore.find(params[:chore_id])

    if chore.child.present?
      head :unprocessable_entity
      return
    end

    chore.child = current_child

    if chore.save
      head :ok
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  def request_payment
    chore = Chore.find(params[:chore_id])
    chore.status = 'completed'

    if chore.save
      head :ok
    else
      render json: transaction.errors, status: :unprocessable_entity
    end
  end

  private

    # TODO this should be based on the auth system
    def current_child
      child = Child.find(params[:child_id])
    end
end
