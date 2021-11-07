class ApplyAccountInterest
  include Interactor

  def call
    target_month = context.target_month

    return if context.account.interest_rate.blank? || context.account.interest_rate.zero?

    return if has_interest_payment?

    return if end_of_month_balance <= 0

    create_interest_payment
  end

  private

    def create_interest_payment
      Transaction.create!(
        account: context.account,
        description: "Monthly Interest Payment",
        # divided twice: integer => float => percent
        amount: end_of_month_balance * context.account.interest_rate / 100.0 / 100.0,
        # TODO there should be some idea around a "default payor"
        payor: context.account.family.parents.first.name,

        transaction_type: :interest
      )
    end

    def has_interest_payment?
      context.account.transactions.interest_payments.where(
        created_at: context.target_month.beginning_of_month...context.target_month.end_of_month,
      ).present?
    end

    def end_of_month_balance
      context.account.balance_at_time(context.target_month.end_of_month)
    end
end
