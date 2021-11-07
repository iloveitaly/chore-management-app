require 'rails_helper'

RSpec.feature "Children", type: :feature, js: true do
  include Capybara::Angular::DSL

  let!(:child) { FactoryGirl.create(:child) }

  it 'views accounts and chore list without authentication' do
    child_chore = FactoryGirl.create(:chore, child_id: child.id, family_id: child.family.id)
    unclaimed_chore = FactoryGirl.create(:chore, family_id: child.family.id)

    visit "/app/#/cmenu/child/#{child.id}"

    expect(page).to have_content(child.accounts.first.name)

    ng_ionic_click_left_nav
    ng_click_on 'Jobs'

    expect(page).to have_content(child_chore.name)

    ng_ionic_list_item_click_on(child_chore.name)

    expect(page).to have_content(child_chore.description)

    # Mark job as completed

    ng_ionic_click_left_nav
    ng_ionic_click_left_nav

    within('ion-side-menu') { ng_click_on 'Jobs' }

    accept_alert { ng_click_on 'Get Paid!' }

    # Claim job

    ng_click_on 'Unclaimed'

    ng_click_on 'Claim'

    wait_until_angular_ready

    expect(page).to have_content('No Jobs to Claim')

    # Ensure claimed job popped up in jobs list

    within('ion-tabs') { ng_click_on 'Jobs' }

    expect(page).to have_content(unclaimed_chore.name)
    expect(page).to have_content('Completed')

    # Pay job (this happens by the parent)

    # TODO this operation should be done on the model level, right now it's on the controller level
    unclaimed_chore.paid_on = DateTime.now
    unclaimed_chore.status = 'paid'
    unclaimed_chore.save

    # refresh chore list
    ng_click_on 'Unclaimed'
    within('ion-tabs') { ng_click_on 'Jobs' }

    expect(page).to_not have_content(unclaimed_chore.name)
  end

  it 'will associate with an existing family if the childs email was already entered' do
    # https://github.com/lucassus/locomotive/blob/9cd7dfd365469fc70fc367f29705a56df9730f6f/spec/features/user_facebook_sign_in_spec.rb
    # https://gist.github.com/kinopyo/1338738

    OmniAuth.config.add_mock(:google_oauth2, {
      :uid => 12345,
      :info => {
        :name => child.name,
        :nickname => 'real',
        :email => child.email,
        :image => 'image'
      }
    })

    visit '/app/'

    ng_click_on 'Sign up'
    ng_click_on 'Sign up with Google Account'

    expect(page).to have_content(child.name)
    expect(page).to have_content("Balance: $0.00")

    ng_ionic_click_left_nav
    ng_click_on 'Logout'

    expect(page).to have_content('Login')
  end
end
