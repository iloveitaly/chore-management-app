require 'rails_helper'

RSpec.describe ApplyAccountInterest, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  let!(:account) { FactoryGirl.create(:account) }

  before do
    transaction_1 = Transaction.create!(
      amount: 10_00,
      description: 'Mowed the lawn',
      account: account,
      payor: 'Mom'
    )

    transaction_2 = Transaction.create!(
      amount: 12_00,
      description: 'Mowed the lawn',
      account: account,
      payor: 'Mom'
    )
  end

  it 'should calculate the balance correctly at a specified date' do
    travel_to DateTime.now.next_month do
      transaction_2 = Transaction.create!(
        amount: 13_00,
        description: 'Future task',
        account: account,
        payor: 'Mom'
      )
    end

    expect(account.balance_at_time(DateTime.now)).to eq(22_00)
  end

  context 'when the account has an interest rate' do
    before { account.interest_rate = 10_00 }

    it 'should create an interest payment' do
      ApplyAccountInterest.call(
        target_month: DateTime.now,
        account: account
      )

      expect(account.transactions.size).to eq(3)
      expect(account.transactions.interest_payments.size).to eq(1)
      expect(account.balance).to eq(22_00 + 2_20)

      interest_payment = account.transactions.interest_payments.first
      expect(interest_payment.account).to eq(account)
      expect(interest_payment.transaction_type).to eq('interest')
      expect(interest_payment.payor).to eq(account.family.parents.first.name)
    end

    it 'does create not an interest payment if one already exists' do
      interest_payment = Transaction.create!(
        amount: 12_00,
        description: 'Interest Payment',
        account: account,
        payor: 'Mom',
        transaction_type: :interest
      )

      previous_balance = account.balance

      ApplyAccountInterest.call(
        target_month: DateTime.now,
        account: account
      )

      expect(account.balance).to eq(previous_balance)
      expect(account.transactions.count).to eq(3)
    end

    it 'does create not an interest payment if balance is negative' do
      expense = FactoryGirl.create :expense, account: account, amount: -(account.balance + 10_00)
      previous_balance = account.balance

      ApplyAccountInterest.call(
        target_month: DateTime.now,
        account: account
      )

      expect(account.balance).to eq(previous_balance)
    end
  end

  context 'when the account has no interest rate set' do
    it 'does not create an interest entry' do
      ApplyAccountInterest.call(
        target_month: DateTime.now,
        account: account
      )

      expect(account.transactions.count).to eq(2)
      expect(account.transactions.interest_payments).to be_empty
    end
  end
end
