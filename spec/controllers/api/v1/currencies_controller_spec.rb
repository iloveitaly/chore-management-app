require 'rails_helper'

RSpec.describe Api::V1::CurrenciesController, type: :controller do
  before do
    @controller.stub(:authenticate_user!)
  end

  it '#index' do
    Currency.create!(name: 'usd', icon: 'the_icon.png')

    process :index, method: :get

    expect(response.code).to eq("200")

    parsed_response = JSON.parse(response.body)
    expect(parsed_response.size).to eq(Currency.count)

    # TODO test currency data
  end
end
