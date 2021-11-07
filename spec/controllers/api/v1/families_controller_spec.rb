require 'rails_helper'

RSpec.describe Api::V1::FamiliesController, type: :controller do
  let(:user) { family.parents.first }
  let!(:family) { FactoryGirl.create(:family) }

  before do
    @request.env["devise.mapping"] = Devise.mappings[:user]
    @request.headers.merge! user.create_new_auth_token

    sign_in :user, user
  end

  it '#show' do
    process :show, method: :get, params: { id: family.id }

    expect(response).to have_http_status(200)

    parsed_family = JSON.parse(response.body)
    expect(parsed_family["name"]).to eq(family.name)
  end

  # NOTE this is used exclusively from the setup/onboarding process
  it '#setup' do
    new_name = Faker::Name.name

    process :setup, method: :post, params: {
      "family" => {
        "name" => new_name,
        "children" => 3.times.map do
          {
            "name" => Faker::Name.name
          }
        end
      }
    }

    expect(response).to have_http_status(200)

    user.family.reload

    expect(user.family.name).to eq(new_name)

    expect(user.family.children.size).to eq(3)
    expect(user.family.accounts.size).to eq(3)

    account = user.family.accounts.first
    expect(account.family).to eq(user.family)
  end
end
