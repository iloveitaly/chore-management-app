FactoryGirl.define do
  factory :child do
    name Faker::Name.name
    email Faker::Internet.email

    family

    after(:create) do |child|
      create(:account, child: child, family: child.family)
    end
  end
end
