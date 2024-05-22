# db/seeds.rb

# Clear existing data
Transaction.destroy_all
Appointment.destroy_all
Patient.destroy_all
InvoiceItem.destroy_all
Invoice.destroy_all
# Service.destroy_all
# User.destroy_all

# Reset primary keys
ActiveRecord::Base.connection.reset_pk_sequence!('transactions')
# ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('patients')
ActiveRecord::Base.connection.reset_pk_sequence!('appointments')
ActiveRecord::Base.connection.reset_pk_sequence!('invoices')
ActiveRecord::Base.connection.reset_pk_sequence!('invoice_items')
# ActiveRecord::Base.connection.reset_pk_sequence!('services')

# # Create some users
# user1 = User.create!(name: 'John Peter', email: 'johnpeter@example.com', title: 'Mr.', password: 'Password123!', password_confirmation: 'Password123!', role: 'admin',
#                      phone: '+1234567890')
# user2 = User.create!(name: 'Jane Smith', email: 'janesmith@example.com', title: 'Dr.', password: 'Password123!', password_confirmation: 'Password123!', role: 'doctor',
#                      phone: '+0987654321')

# # Create some patients
# patient1 = Patient.create!(name: 'Alice Johnson', phone: '+18001234567', user: user2)
# patient2 = Patient.create!(name: 'Bob Brown', phone: '+18007654321', user: user2)

# # Create services
# service1 = Service.create!(name: 'Medical Consultation',
#                            description: 'A general medical consultation to discuss symptoms and issues.', price: 1500000, active: true)
# service2 = Service.create!(name: 'Dental Cleaning', description: 'Professional dental cleaning services.', price: 500000, active: true)

# # Create some appointments
# appointment1 = Appointment.create!(patient: patient1, user: user1, service: service1, status: 'confirmed',
#                                    start_time: DateTime.now + 1.day, end_time: DateTime.now + 1.day + 2.hours, purpose: 'Checkup', description: 'Annual medical checkup')
# appointment2 = Appointment.create!(patient: patient2, user: user1, service: service2, status: 'pending',
#                                    start_time: DateTime.now + 3.days, end_time: DateTime.now + 3.days + 2.hours, purpose: 'Consultation', description: 'Consultation on symptoms')

# # Create invoices
# invoice1 = Invoice.create!(user: user1, start_date: Date.today, end_date: Date.today + 7.days, subtotal: 100_000,
#                            discount: 5000, tax_rate: 5, total: 95_000, notes: 'Thank you for your visit.')

# # Create invoice items
# InvoiceItem.create!(invoice: invoice1, item_name: 'Medical Implants', price: 50_000, quantity: 1, total: 50_000)
# InvoiceItem.create!(invoice: invoice1, item_name: 'Medical Crowns', price: 25_000, quantity: 2, total: 50_000)

# # Create services

# # Adjustments to existing invoice items (if they use services)
# InvoiceItem.find_each do |item|
#   case item.item_name
#   when 'Medical Implants'
#     item.update(invoice: Invoice.first, item_name: service1.name, price: 190_000, quantity: 1, total: 190_000) # Using first invoice and service as an example
#   when 'Medical Crowns'
#     item.update(invoice: Invoice.first, item_name: service2.name, price: 150_000, quantity: 2, total: 300_000)
#   end
# end

# 10.times do |i|
#   Transaction.create!(
#     patient: [patient1, patient2].sample,
#     amount: [100_000, 200_000, 150_000, 230_000, 12_000, 140_000, 123_000].sample,
#     status: %w[Paid Pending Cancelled].sample,
#     payment_method: %w[Cash CreditCard Insurance].sample,
#     created_at: (DateTime.now - i.days)
#   )
# end

# db/seeds.rb

NUMBER_OF_PATIENTS = 40
number_of_users = User.where(role: 'doctor').count
NUMBER_OF_PATIENTS.times do |_i|
  Patient.create!(
    name: Faker::Name.name,
    phone: Faker::PhoneNumber.cell_phone_in_e164,
    email: Faker::Internet.email,
    user_id: User.where(role: 'doctor').pluck(:id).sample, # Assuming each patient is associated with a user
    age: rand(18..100),
    gender: %w[Male Female Other].sample,
    blood_type: ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'].sample
  )
end

# Assuming you already have users and patients created and their IDs are continuous and start from 1.
number_of_patients = Patient.count

# number_of_services = 10 # You want to create 10 services

# # Create Services
# number_of_services.times do |i|
#   Service.create!(
#     name: "Service #{i + 1}",
#     description: "Description for Service #{i + 1}",
#     price: Faker::Commerce.price(range: 1_000_000.0..10_000_000.0).round(2)
#   )
# end

# Fetch all service IDs once created
service_ids = Service.pluck(:id)

# Create Appointments and Invoices spread across the current month
(1..40).each do |i|
  start_time = Faker::Time.between(from: DateTime.now.beginning_of_month, to: DateTime.now.end_of_month)
  end_time = start_time + [30.minutes, 1.hour, 1.5.hours].sample

  appointment = Appointment.create!(
    patient_id: rand(1..number_of_patients),
    user_id: User.where(role: 'doctor').pluck(:id).sample,
    service_id: service_ids.sample,
    start_time:,
    end_time:,
    status: %w[Pending Confirmed Completed Approved Cancelled].sample,
    purpose: "Purpose of visit #{i}",
    description: Faker::Lorem.sentence,
    communication_preferences: %w[email sms].sample
  )

  invoice = Invoice.create!(
    start_date: start_time.to_date,
    end_date: end_time.to_date,
    subtotal: 0,
    discount: [0, 5, 10, 15, 20].sample,
    tax_rate: 0.07,
    total: 0,
    patient_id: appointment.patient_id,
    notes: "Invoice for Appointment #{i}"
  )

  # Create InvoiceItems related to the invoice
  invoice_item_quantity = rand(1..3)
  invoice_item_quantity.times do
    service_id = service_ids.sample
    service_price = Service.find(service_id).price
    quantity = rand(1..3)
    subtotal = service_price * quantity
    InvoiceItem.create!(
      invoice_id: invoice.id,
      service_id:,
      quantity:
    )
    invoice.subtotal += subtotal
  end

  invoice.total = (invoice.subtotal - invoice.discount) * (1 + invoice.tax_rate)
  invoice.save!
end

# Create Transactions for each patient
50.times do
  Transaction.create!(
    amount: Faker::Commerce.price(range: 1_000_000.0..10_000_000.0),
    patient_id: rand(1..number_of_patients),
    status: %w[Paid Pending Cancelled].sample,
    payment_method: %w[Cash CreditCard Insurance].sample
  )
end

puts 'Database seeded successfully!'
