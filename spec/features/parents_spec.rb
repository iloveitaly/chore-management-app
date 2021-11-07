require 'rails_helper'

RSpec.feature "Parents", type: :feature, js: true do
  include Capybara::Angular::DSL

  def click_children_menu
    ng_ionic_click_left_nav
  end

  let!(:user) { FactoryGirl.create(:user) }

  before do
    # https://github.com/lucassus/locomotive/blob/9cd7dfd365469fc70fc367f29705a56df9730f6f/spec/features/user_facebook_sign_in_spec.rb
    # https://gist.github.com/kinopyo/1338738

    OmniAuth.config.add_mock(:google_oauth2, {
      :uid => user.uid,
      :info => {
        :name => user.name,
        :email => user.email,
        :nickname => user.name,
        :image => 'image'
      }
    })
  end

  it 'signs up a parent using an email and password' do
    visit '/app/'

    ng_click_on 'Sign up'

    ng_fill_in 'registration.email', with: 'parent@example.com'
    ng_fill_in 'registration.password', with: 'password'

    ng_click_on 'Sign up', index: 1

    expect(page).to have_content('Tell us about your family!')
  end

  it 'signs up, creates a account, adds a transaction, edits the transaction, and edits the account' do
    visit '/app/'

    ng_click_on 'Sign up'
    ng_click_on 'Sign up with Google Account'

    wait_until_angular_ready

    # Add initial children & accounts

    expect(page).to have_content('Tell us about your family!')

    # NOTE 's are hard to handle with the ng xpath capybara helpers
    child_name_1 = Faker::Name.name.gsub("'", '')
    child_name_2 = Faker::Name.name.gsub("'", '')
    child_name_3 = Faker::Name.name.gsub("'", '')

    ng_fill_in 'child.name', with: child_name_1, index: 0
    ng_fill_in 'child.name', with: child_name_2, index: 1

    ng_click_on 'Add another child'
    ng_fill_in 'child.name', with: child_name_3, index: 3

    ng_click_on 'Next'

    wait_until_angular_ready

    child_1 = Child.find_by(name: child_name_1)

    expect(child_1).to_not be_nil

    expect(Account.find_by(child: child_1)).to_not be_nil
    expect(Account.count).to eq(3)

    # TODO this is a hack around xpath not playing well with searching for strings including single quotes
    #      we need to hack around in this in angular.rb at some point

    # account_name = child_1.accounts.first.name
    account_name = child_1.name

    # Run through the child setup process

    starting_balance = Faker::Number.between(0, 100)

    ng_fill_in 'setup.email', Faker::Internet.email
    ng_click_on 'Next'

    ng_fill_in 'setup.email', Faker::Internet.email
    ng_fill_in 'setup.balance', starting_balance
    ng_click_on 'Next'

    ng_click_on 'Next'

    # Advance through splash screens
    expect(page).to have_content('Congratulations!')

    ng_click_on "Let's Go!"
    ng_click_on "Okay!"
    ng_click_on "Got it!"
    ng_click_on "Got it!"
    ng_click_on "Got it!"
    ng_click_on "Go To My Account"

    # Check left menu to ensure it's initialized

    click_children_menu

    expect(page).to have_content(child_name_1)

    click_children_menu

    # Check initial account list

    expect(page).to have_content(starting_balance)

    # View Account
    # NOTE we intentionally leave this account empty to test the splash screen
    ng_ionic_list_item_click_on account_name

    expect(page).to have_content("No Transaction")

    # Create a Transaction

    ng_click_on 'Record Transaction'

    expect(page).to have_content("Add Transaction")

    transaction_description = 'Mowed the lawn'
    transaction_amount = '100.0'

    ng_fill_in 'transaction.description', transaction_description
    ng_fill_in 'transaction.amount', '-100.0'

    accept_alert { click_on 'Submit' }

    ng_fill_in 'transaction.amount', transaction_amount

    click_on 'Submit'

    expect(page).to have_content(transaction_description)

    ng_ionic_click_right_nav

    expect(page).to have_content('Edit Account')

    wait_until_angular_ready

    updated_account_name = "New Account"

    ng_fill_in 'account.name', updated_account_name
    ng_click_on 'Update'

    expect(page).to have_content(updated_account_name)

    # Add a Child

    # go back to the parent account view
    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Children'

    child_name = Faker::Name.name
    child_email = Faker::Internet.email

    ng_click_on 'Add Child'
    ng_fill_in 'child.name', child_name
    ng_fill_in 'child.email', child_email
    ng_click_on 'Submit'

    expect(page).to have_content(child_name)
    expect(page).to have_content(child_email)

    # Edit Child

    ng_ionic_list_item_click_on child_name, 'Edit'

    updated_child_name = Faker::Name.name
    updated_child_email = Faker::Internet.email

    ng_fill_in 'child.name', updated_child_name
    ng_fill_in 'child.email', updated_child_email
    ng_click_on 'Update'

    expect(page).to have_content(updated_child_name)
    expect(page).to have_content(updated_child_email)

    # Add another account

    # go back to the parent account view
    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Accounts'

    second_account_name = 'Second Account'

    ng_click_on 'Add Account'
    ng_fill_in 'account.name', second_account_name
    # TODO select different currency
    click_on 'Submit'

    expect(page).to have_content(second_account_name)

    # TODO add transaction in separate currency

    # View the account settings page
    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Settings'

    expect(page).to have_content(user.name)

    # Add second account to child, split schedule

    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Accounts'
    ng_click_on 'Add Account'

    second_child_account_name = Faker::Name.name
    child_with_account = Child.find_by(name: child_name_3)

    ng_fill_in 'account.name', second_child_account_name
    ng_fill_in 'account.child_id', child_with_account.name

    ng_click_on 'Submit'

    wait_until_angular_ready

    # Add split schedule to the child

    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Children'

    ng_ionic_list_item_click_on child_with_account.name, 'Edit'

    ng_toggle 'child.split_earnings'

    ng_fill_in 'account.split_percentage', with: '20', index: 0
    ng_fill_in 'account.split_percentage', with: '79', index: 1

    accept_alert { ng_click_on 'Update' }

    ng_fill_in 'account.split_percentage', with: '80', index: 1

    ng_click_on 'Update'

    wait_until_angular_ready

    child_with_account.reload

    expect(child_with_account.split_earnings).to be true

    expect(child_with_account.accounts.first.split_percentage).to eq(20)
    expect(child_with_account.accounts.last.split_percentage).to eq(80)

    # Navigate back to the first account we created

    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Accounts'

    ng_ionic_list_item_click_on(updated_account_name)

    # Edit the first transaction we created

    expect(page).to have_content(updated_account_name)
    expect(page).to have_content(transaction_description)

    ng_ionic_list_item_click_on(transaction_description)

    # NOTE currency symbol is used intentionally to test messy input
    ng_fill_in 'transaction.amount', '$120'
    ng_fill_in 'transaction.description', 'Cut the grass'
    click_on 'Update'

    wait_until_angular_ready

    expect(page).to have_content('120.00')
    expect(page).to have_content('Cut the grass')

    # Create a expense

    ng_click_on 'Record Transaction'
    ng_click_on 'Expense'

    expense_amount = '  50.00  '
    expense_description = Faker::Lorem.sentence
    expense_payee = Faker::Company.name

    ng_fill_in('transaction.amount', expense_amount)
    ng_fill_in('transaction.description', expense_description)
    ng_fill_in('transaction.payee', expense_payee)

    click_on 'Submit'

    # 70 == current balance
    # 3 transactions because of the initial balance transaction
    expect(page).to have_content('70.00')
    expect(Transaction.count).to eq(3)

    # Delete the account

    ng_ionic_click_right_nav
    accept_alert { click_on 'Delete Account' }

    expect(page).to_not have_content(updated_account_name)
    expect(page).to have_content(second_account_name)

    # Add a Job

    click_children_menu
    ng_click_on 'Family Dashboard'
    ng_click_on 'Jobs'

    ng_click_on 'Add Job'

    child_with_account = Child.find_by(name: child_name_3)

    chore_name = Faker::Lorem.word
    chore_value = Faker::Number.between(0, 100)

    ng_fill_in 'chore.name', chore_name
    ng_fill_in 'chore.value', chore_value
    ng_fill_in 'chore.description', Faker::Lorem.sentence
    ng_fill_in 'chore.child_id', child_with_account.name

    ng_click_on 'Create'

    expect(page).to have_content(chore_name)

    # Pay the job

    ng_click_on 'Pay'

    ng_fill_in 'chore.account_id', child_with_account.accounts.name

    ng_click_on 'Pay'

    wait_until_angular_ready

    expect(page).to_not have_content(chore_name)

    # Create another job

    new_chore_name = Faker::Lorem.word
    new_chore_value = Faker::Number.between(0, 100)

    ng_click_on 'Add Job'

    ng_fill_in 'chore.name', new_chore_name
    ng_fill_in 'chore.value', new_chore_value
    ng_fill_in 'chore.description', Faker::Lorem.sentence
    ng_fill_in 'chore.child_id', child_with_account.name

    ng_click_on 'Create'

    expect(page).to have_content(new_chore_name)

    # Update the job

    ng_ionic_list_item_click_on new_chore_name

    updated_chore_name = Faker::Lorem.word

    ng_fill_in 'chore.name', updated_chore_name

    ng_click_on 'Update'

    expect(page).to have_content(updated_chore_name)

    # Delete the job

    ng_ionic_list_item_click_on updated_chore_name

    accept_alert { ng_click_on 'Delete Job' }

    expect(page).to have_content("No Jobs")

    # Logout

    click_children_menu
    ng_click_on 'Logout'

    expect(page).to have_content('Login')

    ng_click_on 'Login'
    ng_click_on 'Login with Google Account'


    # there's a bug somewhere causing the family name to be messed with
    # expect(page).to have_content("#{user.family.name} Family")
    expect(page).to have_content("Family")

    # TODO test transfer
    # TODO associate account with child
    # TODO inline account edit child create
    # TODO inline account create child create
    # TODO edit expense
    # TODO test child dashboard
  end
end
