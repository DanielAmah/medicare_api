FactoryBot.define do
  factory :user do
    name { "John Doe" }
    phone { Faker::PhoneNumber.cell_phone_in_e164}
    email { Faker::Internet.email }
    password { "securepassword" }
    password_confirmation { "securepassword" }
    role { "admin" }
    title { "Mr." }
  end
end
