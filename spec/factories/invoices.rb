# spec/factories/invoices.rb
FactoryBot.define do
  factory :invoice do
    association :patient  # Ensure you have a factory for Patient defined

    subtotal { "100.0" }
    discount { "5.0" }  # Arbitrary example discount
    tax_rate { "7.5" }  # Arbitrary example tax rate percentage
    total { "102.75" }  # Total calculated with the consideration of the discount and tax

    # Using transient attributes to easily create invoice items when needed
    transient do
      items_count { 3 }
    end

    # After creating an Invoice, you can create several invoice items using the `items_count` declared above
    after(:create) do |invoice, evaluator|
      create_list(:invoice_item, evaluator.items_frame, invoice: invoice)
    end

    # You can also define traits for specific scenarios, like having zero discount or tax
    trait :no_discount do
      discount { "0.0" }
    end

    trait :no_tax do
      tax_rate { "0.0" }
    end

    # Another trait could be for invoices where the calculations are simple or have edge values
    trait :simple_calculation do
      subtotal { "100.0" }
      discount { "0.0" }
      tax_rate { "10.0" }
      total { "110.0" }
    end
  end
end
