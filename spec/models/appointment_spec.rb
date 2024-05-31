require 'rails_helper'

RSpec.describe Appointment, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:patient) }
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:service) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:purpose) }

  end


  describe '#update_status' do
    let(:appointment) { create(:appointment, start_time: 1.day.ago, end_time: 1.day.from_now, status: 'Pending') }

    context 'when the start time is in the past' do
      it 'updates the status to Completed' do
        appointment.update_status
        expect(appointment.status).to eq('Completed')
      end
    end

    context 'when the appointment is already completed' do
      before { appointment.status = 'Completed' }

      it 'does not change the status' do
        appointment.update_status
        expect(appointment.status).to eq('Completed')
      end
    end
  end

  describe '#set_communication_methods' do
    let(:appointment) { create(:appointment) }

    it 'sets the communication preferences based on given methods' do
      appointment.set_communication_methods([:email, :sms])
      expect(appointment.communication_preferences).to eq('3')
    end
  end

  describe '#communication_enabled?' do
    let(:appointment) { create(:appointment, communication_preferences: '3') }  # Binary 11 => email and sms

    it 'returns true if communication method is enabled' do
      expect(appointment.communication_enabled?(:email)).to be true
      expect(appointment.communication_enabled?(:sms)).to be true
    end

    it 'returns false if communication method is not enabled' do
      expect(appointment.communication_enabled?(:whatsapp)).to be false
    end
  end
end
