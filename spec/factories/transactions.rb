# spec/factories/transactions.rb
FactoryBot.define do
  factory :transaction do
    association :patient

    amount { Faker::Commerce.price(range: 0.01..1000.00) }
    status { %w[Paid Pending Cancelled].sample }
    payment_method { %w[Cash CreditCard Insurance].sample }

    trait :paid do
      status { 'Paid' }
    end

    trait :pending do
      status { 'Pending' }
    end

    trait :cancelled do
      status { 'Cancelled' }
    end

    trait :cash_payment do
      payment_method { 'Cash' }
    end

    trait :credit_card_payment do
      payment_method { 'CreditCard' }
    end

    trait :insurance_payment do
      payment_method { 'Insurance' }
    end
  end
end
