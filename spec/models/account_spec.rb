require 'rails_helper'

RSpec.describe Account, type: :model do
  let(:child) { FactoryGirl.create(:child) }

  describe 'split transactions' do
    it 'should be enabled if enabled on the child level' do
      child.update(split_earnings: true)
      account = FactoryGirl.create(:account, child: child)

      expect(account.split_income?).to be true
    end

    it 'should be disabled if disbled on the child level' do
      child.update(split_earnings: false)
      account = FactoryGirl.create(:account, child: child)

      expect(account.split_income?).to be false
    end

    it 'should be disabled if currency is not the default currency of the child' do
      child.update(split_earnings: true)

      expect(child).to receive(:default_currency).and_return(Currency.account_default)

      account = FactoryGirl.create(:account, child: child)
      account.currency = Currency.find_by(name: 'CAD')
      account.save

      expect(account.split_income?).to be false
    end

    it 'should be disabled if the account is not associated with a child' do
      account_without_child = FactoryGirl.create(:account)

      expect(account_without_child.split_income?).to be false
    end
  end
end
