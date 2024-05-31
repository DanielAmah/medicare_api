# spec/factories/patients.rb
FactoryBot.define do
  factory :patient do
    association :user, factory: :user # Make sure you have a user factory defined

    name { Faker::Name.name }
    phone { Faker::PhoneNumber.cell_phone_in_e164 }
    age { rand(1..100) }
    gender { %w[Male Female Other].sample }
    blood_type { %w[A+ A- B+ B- AB+ AB- O+ O-].sample }

    # Assuming you have set up Active Storage correctly and have an uploader
    after(:build) do |patient|
      patient.profile_image.attach(
        io: File.open(Rails.root.join('spec', 'fixtures', 'files', 'test_image.jpg')),
        filename: 'test_image.jpg',
        content_type: 'image/jpg'
      )
    end

    trait :with_appointments do
      after(:create) do |patient|
        create_list(:appointment, 3, patient:)
      end
    end

    trait :with_transactions do
      after(:create) do |patient|
        create_list(:transaction, 2, patient:)
      end
    end

    trait :with_invoices do
      after(:create) do |patient|
        create_list(:invoice, 2, patient:)
      end
    end
  end
end
