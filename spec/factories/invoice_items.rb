FactoryBot.define do
  factory :invoice_item do
    association :invoice
    association :service

    quantity { rand(1..10) }


    unit_price { rand(10.0..100.0).round(2) }

    total_price { quantity * unit/price }

    trait :high_quantity do
      quantity { 100 }
    end

    trait :zero_quantity do
      quantity { 0 }
    end
  end
end

