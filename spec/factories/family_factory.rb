FactoryGirl.define do
  factory :family do
    name { Faker::Name.last_name }

    after(:create) { |family| create(:user, family: family) }
  end
end
