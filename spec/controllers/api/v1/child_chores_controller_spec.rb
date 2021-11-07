require 'rails_helper'

RSpec.describe Api::V1::ChildChoresController, type: :controller do
  basic_family

  let!(:unclaimed_chore) { FactoryGirl.create(:chore, child_id: nil,family_id: family.id) }
  let!(:assigned_chore) { FactoryGirl.create(:chore, child_id: child.id, family_id: family.id) }

  it '#index' do
    process :index, method: :get, params: { child_id: child.id }

    expect(response).to have_http_status(200)

    expect(parsed_response.size).to eq(1)
    expect(parsed_response.first["id"]).to eq(assigned_chore.id)
  end

  it '#unclaimed' do
    process :unclaimed, method: :get, params: { child_id: child.id }

    expect(response).to have_http_status(200)

    expect(parsed_response.size).to eq(1)
    expect(parsed_response.first["id"]).to eq(unclaimed_chore.id)
  end

  describe '#claim' do
    it 'cannot claim already claimed jobs' do
      process :claim, method: :post, params: {
        child_id: child.id,
        chore_id: assigned_chore.id
      }

      expect(response).to_not have_http_status(200)
    end

    it 'claims unclaimed job' do
      process :claim, method: :post, params: {
        child_id: child.id,
        chore_id: unclaimed_chore.id
      }

      expect(response).to have_http_status(200)

      unclaimed_chore.reload
      expect(unclaimed_chore.child_id).to eq(child.id)
    end

    skip 'cannot claim a job that is not assigned to the family' do

    end
  end

  it '#request_payment' do
    process :request_payment, method: :post, params: {
      child_id: child.id,
      chore_id: assigned_chore.id
    }

    expect(response).to have_http_status(200)

    assigned_chore.reload
    expect(assigned_chore.status).to eq('completed')
  end
end
