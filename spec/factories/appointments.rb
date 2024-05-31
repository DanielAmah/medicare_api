# spec/factories/appointments.rb
FactoryBot.define do
  factory :appointment do
    association :patient
    association :user
    association :service
    start_time { 3.days.from_now }
    end_time { 4.days.from_now }
    status { Appointment.statuses.keys.sample }
    purpose { "Routine check-up" }

    # You may optionally include a trait for each status for easy testing
    Appointment.statuses.each_key do |status|
      trait status.downcase.to_sym do
        status { status }
      end
    end

    # Traits for communication methods if necessary
    trait :email_communication do
      communication_preferences { Appointment.communications[:email].to_s }
    end

    trait :sms_communication do
      communication_preferences { Appointment.communications[:sms].to_s }
    end

    trait :whatsapp_communication do
      communication_preferences { Appointment.communications[:whatsapp].to_s }
    end

    # Setup dynamic communication combinations if needed
    trait :multi_communication do
      communication_preferences do
        (Appointment.communications[:email] |
         Appointment.communications[:sms] |
         Appointment.communications[:whatsapp]).to_s
      end
    end
  end
end
