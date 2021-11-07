FactoryGirl.define do
  factory :chore do
    name { Faker::Name.name }
    description { Faker::Lorem.sentence }
    value { Faker::Number.between(0, 100) }

    # child
    family
    # user
  end
end
