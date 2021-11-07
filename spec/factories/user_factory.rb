FactoryGirl.define do
  factory :user do
    email { Faker::Internet.email }
    name { Faker::Name.name }

    uid { Faker::Number.positive }
    provider 'google_oauth2'

    password "password"
  end
end
