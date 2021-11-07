require 'rails_helper'

RSpec.describe Api::V1::AccountsController, type: :controller do
  before do
    @controller.stub(:authenticate_user!)
  end

  let(:account) { FactoryGirl.create(:account) }

  it '#index' do

  end

  it '#show' do
    process :show, method: :get, params: { id: account.id }

    expect(response).to have_http_status(200)

    expect(parsed_response["split_percentage"]).to eq(0)
  end

  it '#destroy' do
    process :destroy, method: :delete, params: { id: account.id }

    expect(Account.count).to eq(0)

    account.reload

    expect(account.deleted_at).to_not be_nil
  end

  it '#update' do
    second_child = FactoryGirl.create(:child)

    process :update, method: :patch, params: { "id" => account.id, "account" => {
      "interest_rate" => 10_00,
      "name" => "New Name",
      "position" => 1,
      "child_id" => second_child.id
    } }

    expect(response.code).to eq('201')

    account.reload
    expect(account.interest_rate).to eq(10_00)
    expect(account.name).to eq('New Name')
    expect(account.child).to eq(second_child)
  end
end
