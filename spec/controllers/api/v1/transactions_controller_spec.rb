require 'rails_helper'

RSpec.describe Api::V1::TransactionsController, type: :controller do
  let!(:account) { FactoryGirl.create(:account) }
  let!(:other_account) { FactoryGirl.create(:account) }

  let!(:user) { FactoryGirl.create(:user) }
  let(:family) { user.family }

  # TODO refactor to user factories
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers.merge! user.create_new_auth_token

    request.env["CONTENT_TYPE"] = "application/json"

    sign_in :user, user
  end

  # TODO test user auth

  it '#index' do
    transaction = Transaction.create!(
      amount: 100.0,
      description: 'toy',
      account: account
    )

    process :index, method: :get, params: { account_id: account }

    expect(response).to have_http_status(200)
  end

  it '#show' do
    transaction = FactoryGirl.create(:transaction)

    process :show, method: :get, params: { id: transaction.id }

    expect(response).to have_http_status(200)
  end

  it '#update' do
    transaction = FactoryGirl.create(:transaction)

    process :update, method: :patch, params: { id: transaction.id, transaction: {
      amount: '12.21',
      description: 'updated description',
      payor: "Bob Bianco"
    } }

    expect(response).to have_http_status(200)

    transaction = Transaction.find(transaction.id)
    expect(transaction.amount).to eq(12_21)
    expect(transaction.description).to eq('updated description')
    expect(transaction.payor).to eq('Bob Bianco')
  end

  describe '#create' do
    it 'creates a standard transaction' do
      process :create, method: :post, params: { "account_id" => account.id, "transaction" => {
        "amount" => '11.01',
        "description" => "bla bla bla",
        "payor"=>"Michael Bianco"
      } }

      expect(response).to have_http_status(201)

      transaction = Transaction.last
      expect(transaction).to_not be_nil
      expect(transaction.amount).to eq(11_01)
    end

    it 'creates a split transaction' do
      child = FactoryGirl.create(:child, family: family, split_earnings: true)

      account.update(child: child, split_percentage: 20)
      other_account.update(child: child, split_percentage: 30)
      third_account = FactoryGirl.create(:account, child: child, split_percentage: 50)

      process :create, method: :post, params: {
        "account_id" => account.id,
        "type" => "income",
        "split_income" => true,
        "transaction" => {
          "amount" => '20.00',
          "description" => "so much split",
          "payor" => "Michael Bianco",
        }
      }

      expect(response).to have_http_status(201)

      expect(account.transactions.size).to eq(1)
      expect(other_account.transactions.size).to eq(1)
      expect(third_account.transactions.size).to eq(1)

      expect(account.transactions.first.amount).to eq(20 * 0.20 * 100)
      expect(other_account.transactions.first.amount).to eq(20 * 0.30 * 100)
      expect(third_account.transactions.first.amount).to eq(20 * 0.50 * 100)

      transaction = account.transactions.first
      expect(transaction.description).to eq('so much split (20%)')
      expect(transaction.account).to eq(account)
    end

    xit 'does not accept a negative number' do
      process :create, method: :post, params: {
        "account_id" => account.id,
        "transaction" => {
          "amount" => '-11.01',
          "description" => "bla bla bla",
          "payor"=>"Michael Bianco"
        }
      }

      expect(response).to have_http_status(422)
    end

    # TODO https://github.com/iloveitaly/family-currency/issues/35
    # TODO messy number + expense type should be accepted on the API side, and ignored on the client side
    xit 'accepts messy number input' do
      process :create, method: :post, params: {
        "account_id" => account.id,
        "transaction" => {
          "amount" => '  11.01 marbles  ',
          "description" => Faker::Lorem.word,
          "payor"=>"Michael Bianco"
        }
      }

      expect(response).to have_http_status(201)

      transaction = Transaction.last
      expect(transaction).to_not be_nil
      expect(transaction.amount).to eq(11_01)
    end

    context 'transfer' do
      it 'created if account currencies are identical' do
        process :create, method: :post, params: {
          "type" => "transfer",
          "destination_account" => other_account.id,
          "account_id" => account.id,
          "transaction" => {
            "description" => "A great description",
            "amount" => "11.02"
          }
        }

        expect(response).to have_http_status(201)

        expect(Transaction.count).to eq(2)

        expect(account.balance).to eq(-11_02)
        expect(account.transactions.first.transaction_type).to eq('transfer')

        expect(other_account.balance).to eq(11_02)
        expect(other_account.transactions.first.transaction_type).to eq('transfer')
      end

      it 'not created if account currencies are different' do
        other_account.update :currency => Currency.where.not(id: account.id).sample

        process :create, method: :post, params: {
          "type" => "transfer",
          "destination_account" => other_account.id,
          "account_id" => account.id,
          "transaction" => {
            "description" => "A great description",
            "amount" => "11.02"
          }
        }

        expect(response).to have_http_status(422)
        # TODO test error message
      end
    end
  end
end
