require 'rails_helper'

RSpec.describe SendChildAccountUpdates, type: :model do
  let!(:child) { FactoryGirl.create(:child) }
  let!(:child_without_email) { FactoryGirl.create(:child, email: nil) }

  it 'sends an email with a account update' do
    FactoryGirl.create :transaction, account: child.accounts.first

    # TODO update should serialize and save the field
    child.update_email_schedule('weekly', DateTime.now.wday)
    child.save

    expect(SendChildAccountUpdates).to receive(:call).exactly(1).times

    SendChildAccountUpdates.call
  end
end
