require 'rails_helper'

RSpec.describe Child, type: :model do
  let(:child) { FactoryGirl.create(:child) }
  let(:serializer) { ChildSerializer.new(child) }

  describe "#balance_by_currency" do
    let(:account) { FactoryGirl.create(:account, child: child) }
    let(:cad_account) { FactoryGirl.create(:account, child: child, currency: Currency.find_by(name: 'CAD')) }

    let!(:transaction_1) { FactoryGirl.create(:transaction, account: account) }
    let!(:transaction_2) { FactoryGirl.create(:transaction, account: account) }

    let!(:transaction_cad_1) { FactoryGirl.create(:transaction, amount: 10, account: cad_account) }
    let!(:transaction_cad_2) { FactoryGirl.create(:transaction, amount: 20, account: cad_account) }

    it 'properly generates total balance for a currency' do
      expect(child.balance_by_currency).to eq([
        {:currency=>"USD", :currency_id=>1, :balance=> transaction_1.amount + transaction_2.amount},
        {:currency=>"CAD", :currency_id=>2, :balance=> transaction_cad_1.amount + transaction_cad_2.amount}
      ])
    end
  end

  describe '#default_currency' do
    it 'should default to usd if none exists' do
      child.accounts.delete_all

      expect(child.accounts).to be_empty
      expect(child.default_currency).to eq(Currency.account_default)
    end

    it 'should default to the most commonly used real currency' do
      cad = Currency.find_by(name: 'CAD')

      FactoryGirl.create(:account, family: child.family, child: child, currency: cad)
      FactoryGirl.create(:account, family: child.family, child: child, currency: cad)

      expect(child.accounts.size).to eq(3)
      expect(child.default_currency).to eq(cad)
    end
  end

  describe 'serializer' do
    describe 'email frequency' do
      it 'defaults to saturday at 5am' do
        expect(serializer.email_frequency).to eq('weekly')
        expect(serializer.email_day).to eq(1)
      end

      it 'sets a monthly schedule' do
        child.update_email_schedule('monthly', 15)

        expect(serializer.email_frequency).to eq('monthly')
        expect(serializer.email_day).to eq(15)
      end

      it 'sets to a weekly schedule' do
        child.update_email_schedule('weekly', 2)

        expect(serializer.email_frequency).to eq('weekly')
        expect(serializer.email_day).to eq(2)
      end
    end
  end
end
