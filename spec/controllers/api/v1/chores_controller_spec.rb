require 'rails_helper'

RSpec.describe Api::V1::ChoresController, type: :controller do
  let!(:child) { FactoryGirl.create(:child) }
  let(:family) { child.family }
  let(:user) { family.parents.first }

  # TODO DRY this up! Make this a shared rspec helper method
  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers.merge! user.create_new_auth_token

    sign_in :user, user
  end

  it '#index' do
    chore_a = FactoryGirl.create(:chore, family_id: family.id)
    chore_b = FactoryGirl.create(:chore, family_id: family.id)

    process :index, method: :get

    expect(response).to have_http_status(200)

    parsed_response = JSON.parse(response.body)
    expect(parsed_response.size).to eq(2)

    # TODO test additional fields
  end

  it '#create' do
    name = Faker::Name.name
    description = Faker::Lorem.sentence

    process :create, method: :post, params: {
      "chore" => {
        "name" => name,
        "description" => description,
        "child_id" => child.id
      }
    }

    expect(response).to have_http_status(200)

    chore = Chore.all.first

    expect(chore.family).to eq(family)
    expect(chore.child).to eq(child)

    expect(chore.name).to eq(name)
    expect(chore.description).to eq(description)
  end

  it '#update' do
    chore = FactoryGirl.create(:chore)

    new_child = FactoryGirl.create(:child, family: chore.family)
    new_name = Faker::Name.name
    new_description = Faker::Lorem.sentence

    process :update, method: :put, params: {
      id: chore.id,
      "chore" => {
        "name" => new_name,
        "description" => new_description,
        "child_id" => new_child.id
      }
    }

    expect(response).to have_http_status(201)

    fresh_chore = Chore.find(chore.id)
    expect(fresh_chore.name).to eq(new_name)
    expect(fresh_chore.description).to eq(new_description)
    expect(fresh_chore.description).to eq(new_description)
    expect(fresh_chore.child).to eq(new_child)
  end

  it '#destroy' do
    chore = FactoryGirl.create(:chore)

    process :destroy, method: :delete, params: { id: chore.id }

    expect(response).to have_http_status(200)

    expect { Chore.find(chore.id) }.to raise_error(ActiveRecord::RecordNotFound)
  end

  describe '#pay' do
    let(:chore) { FactoryGirl.create(:chore) }
    let(:account) { child.accounts.first }

    it 'a standard job' do
      process :pay, method: :post, params: {
        "chore_id" => chore.id,

        # TODO I'm unsure why this isn't included in the chores param
        #      when the payload is received from angular
        "account_id" => account.id,

        "chore" => {
          "value" => chore.value,
        }
      }

      expect(response).to have_http_status(200)

      chore.reload
      expect(chore.paid_on).to_not be_nil
      expect(chore.status).to eq('paid')

      # NOTE the value of the chore is not currency-specific
      account.reload
      expect(account.balance).to eq(chore.value * 100)
    end

    it 'a recurring job' do
      chore.update(recurring: true)

      process :pay, method: :post, params: {
        "chore_id" => chore.id,
        "account_id" => account.id,

        "chore" => {
          "value" => chore.value,
        }
      }

      expect(response).to have_http_status(200)

      expect(parsed_response['new_chore_id']).to_not be_nil

      new_chore = Chore.find(parsed_response['new_chore_id'])
      expect(new_chore.status).to eq('open')
      expect(new_chore.paid_on).to be_nil

      chore.reload
      expect(chore.paid_on).to_not be_nil
      expect(chore.status).to eq('paid')

      # NOTE the value of the chore is not currency-specific
      account.reload
      expect(account.balance).to eq(chore.value * 100)
    end
  end
end
