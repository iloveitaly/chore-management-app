require 'rails_helper'

RSpec.describe Api::V1::ChildrenController, type: :controller do
  let(:child) { FactoryGirl.create(:child) }
  let(:family) { child.family }
  let(:user) { family.parents.first }

  # TODO DRY this up! Make this a shared rspec helper method
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers.merge! user.create_new_auth_token

    sign_in :user, user
  end

  describe '#show' do
    it 'properly renders a child' do
      process :show, method: :get, params: { id: child.id }

      expect(response).to have_http_status(200)

      expect(parsed_response['id']).to eq(child.id)
      expect(parsed_response['has_user_account']).to be false
      expect(parsed_response['default_currency_id']).to eq(Currency.account_default.id)
      expect(parsed_response['split_earnings']).to be false
      expect(parsed_response['count_of_accounts']).to eq(1)
      expect(parsed_response['balance_by_currency']).to eq([
        {
          'currency_id' => 1,
          'currency' => 'USD',
          'balance' => 0
        }
      ])
    end

    it 'properly indicates when a child is associated with a user' do
      child_user = FactoryGirl.create(:user)
      child_user.child = child
      child_user.save!

      process :show, method: :get, params: { id: child.id }

      expect(response).to have_http_status(200)

      expect(parsed_response['has_user_account']).to be true
    end
  end

  describe '#setup' do
    it 'sets up an account' do
      account = child.accounts.first
      new_account_currency = Currency.all.sample
      new_email = Faker::Internet.email

      process :setup, method: :post, params: {
        child_id: child.id,
        "balance" => 10_00,
        "email" => new_email,
        "currency_id" => new_account_currency.id
      }

      expect(response).to have_http_status(200)

      account.reload

      expect(account.currency).to eq(new_account_currency)
      # TODO this should be normalized
      expect(account.balance).to eq(10_00 * (new_account_currency.zero_decimal ? 1 : 100))

      child.reload
      expect(child.email).to eq(new_email)
    end

    it 'skips the setup process if empty params are passed' do
      process :setup, method: :post, params: {
        child_id: child.id
      }

      expect(response).to have_http_status(200)

      parsed_response = JSON.parse(response.body)
      expect(parsed_response["next_child"]).to be_nil
    end
  end

  describe '#create' do
    it 'creates a child and sends them a notification email' do
      expect(SendChildEmail).to receive(:call).once

      random_name = Faker::Name.name
      random_email = Faker::Internet.email

      process :create, method: :post, params: { "child" => {
        "name" => random_name,
        "email" => random_email
      } }

      expect(response).to have_http_status(201)

      child = Child.find_by(name: random_name)
      expect(child.name).to eq(random_name)
      expect(child.email).to eq(random_email)
      expect(child.family).to eq(user.family)
    end

    it 'cleans a mess child email to ensure a match during login' do
      random_name = Faker::Name.name

      process :create, method: :post, params: { "child" => {
        "name" => random_name,
        "email" => "  MessyEmail@Example.com    "
      } }

      expect(response).to have_http_status(201)

      child = Child.find_by(name: random_name)
      expect(child.email).to eq('messyemail@example.com')
    end
  end

  describe '#update' do
    it 'updates name and email' do
      new_name = Faker::Name.name
      new_email = Faker::Internet.email

      process :update, method: :put, params: {
        id: child.id,
        "child" => {
          "name" => new_name,
          "email" => new_email
        }
      }

      expect(response).to have_http_status(200)

      fresh_child = Child.find(child.id)

      expect(fresh_child.name).to eq(new_name)
      expect(fresh_child.email).to eq(new_email)
    end

    it 'updates email frequency' do
      new_name = Faker::Name.name

      process :update, method: :put, params: {
        id: child.id,
        "child" => { "name" => new_name },
        "email_frequency" => 'monthly',
        "email_month_day" => '15',
        "email_week_day" => '2'
      }

      expect(response).to have_http_status(200)

      fresh_child = Child.find(child.id)
      serializer = ChildSerializer.new(fresh_child)
      expect(fresh_child.name).to eq(new_name)
      expect(serializer.email_day).to eq(15)
      expect(serializer.email_frequency).to eq('monthly')
    end

    it 'updates split schedule' do
      FactoryGirl.create(:account, child: child, family: child.family)

      expect(child.accounts.size).to eq(2)

      account_1 = child.accounts.first
      account_2 = child.accounts.last

      process :update, method: :put, params: {
        id: child.id,
        "child" => {
          "split_earnings" => true,
        },
        "split_earnings_schedule" => [
          {
            account_id: account_1.id,
            split_percentage: "50",
          },
          {
            account_id: account_2.id,
            split_percentage: "50",
          }
        ]
      }

      expect(response).to have_http_status(200)

      account_1.reload
      expect(account_1.split_percentage).to eq(50)

      account_2.reload
      expect(account_2.split_percentage).to eq(50)
    end

  end
end
