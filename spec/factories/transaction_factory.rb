FactoryGirl.define do
  factory :transaction do
    amount 100.0
    description 'toy'
    account
  end

  factory :expense, class: Transaction do
    amount -10_00
    description { Faker::Lorem.words }
    payor { Faker::Name.name }
    account
  end
end
