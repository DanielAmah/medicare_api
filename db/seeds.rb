# db/seeds.rb

# Clear existing data
Transaction.destroy_all
Appointment.destroy_all
Patient.destroy_all
InvoiceItem.destroy_all
Invoice.destroy_all
Service.destroy_all
User.destroy_all

# Reset primary keys
ActiveRecord::Base.connection.reset_pk_sequence!('transactions')
ActiveRecord::Base.connection.reset_pk_sequence!('users')
ActiveRecord::Base.connection.reset_pk_sequence!('patients')
ActiveRecord::Base.connection.reset_pk_sequence!('appointments')
ActiveRecord::Base.connection.reset_pk_sequence!('invoices')
ActiveRecord::Base.connection.reset_pk_sequence!('invoice_items')
ActiveRecord::Base.connection.reset_pk_sequence!('services')

# Create some users
user1 = User.create!(name: 'John Peter', email: 'johnpeter@gmail.com', title: 'Mr.', password: 'Password123!', password_confirmation: 'Password123!', role: 'admin',
                     phone: '+1234567890')
user2 = User.create!(name: 'Jane Smith', email: 'janesmith@gmail.com', title: 'Dr.', password: 'Password123!', password_confirmation: 'Password123!', role: 'doctor',
                     phone: '+0987654321')
user3 = User.create!(name: 'Bryce Aron', email: 'brycearon@gmail.com', title: 'Dr.', password: 'Password123!', password_confirmation: 'Password123!', role: 'doctor',
                     phone: '+0987654321')

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

service1 = Service.create!(name: 'Laboratory Services',
                           description: 'Blood tests, urinalysis, and other lab tests to help diagnose and monitor diseases.', price: 150_000, active: true)
service2 = Service.create!(name: 'Pathology',
                           description: 'Examination of tissues, cells, and organs to diagnose diseases', price: 3_000_000, active: true)
service3 = Service.create!(name: 'General Surgery',
                           description: 'Surgical procedures on various parts of the body, including the abdomen, skin, and soft tissues.', price: 7_500_000, active: true)
service4 = Service.create!(name: 'Cardiology',
                           description: 'Diagnosis and treatment of heart diseases and conditions.', price: 9_500_000, active: true)
service5 = Service.create!(name: 'Psychiatry',
                           description: 'Medical treatment for mental health disorders, including medication management.', price: 5_700_000, active: true)
service6 = Service.create!(name: 'Counseling Services',
                           description: 'Individual, family, and group therapy sessions to support mental health.', price: 5_700_000, active: true)

# Fetch all service IDs once created
service_ids = Service.pluck(:id)

# Create Appointments and Invoices spread across the current month
(1..50).each do |i|
  created_time = rand(DateTime.now.beginning_of_year..DateTime.now)
  start_time = created_time
  end_time = start_time + [30.minutes, 1.hour, 1.5.hours, 2.hours].sample

  appointment = Appointment.create!(
    patient_id: rand(1..number_of_patients),
    user_id: User.where(role: 'doctor').pluck(:id).sample,
    service_id: service_ids.sample,
    start_time:,
    end_time:,
    status: %w[Pending Confirmed Completed Approved Cancelled].sample,
    purpose: "Purpose of visit #{i}",
    description: Faker::Lorem.sentence,
    communication_preferences: %w[email sms].sample,
    created_at: created_time,
    updated_at: created_time
  )

  invoice = Invoice.create!(
    start_date: start_time.to_date,
    end_date: end_time.to_date,
    subtotal: 0,
    discount: [0, 5000, 10000, 15000, 20000].sample,
    tax_rate: 0.07,
    total: 0,
    patient_id: appointment.patient_id,
    notes: "Invoice for Appointment #{i}",
    created_at: created_time,
    updated_at: created_time
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
      quantity:,
      created_at: created_time,
      updated_at: created_time
    )
    invoice.subtotal += subtotal
  end

  invoice.total = (invoice.subtotal - invoice.discount) * (1 + invoice.tax_rate)
  invoice.save!

  Transaction.create!(
    amount: invoice.total,
    patient_id: appointment.patient_id,
    status: %w[Paid Pending Cancelled].sample,
    payment_method: %w[Cash CreditCard Insurance].sample,
    created_at: created_time,
    updated_at: created_time
  )
end

puts 'Database seeded successfully!'
