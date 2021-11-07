FactoryGirl.define do
  factory :account do
    name { Faker::Name.first_name }
    association :family
    currency { Currency.account_default }
  end
end
