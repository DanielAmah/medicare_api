class Appointment < ApplicationRecord
  before_save :set_initial_status
  belongs_to :patient
  belongs_to :user
  belongs_to :service

  validates :start_time, :end_time, :status, :purpose, presence: true
  validates :status, presence: true,
                     inclusion: { in: %w[Pending Confirmed Completed Approved Cancelled], message: '%<value>s is not a valid status' }

  enum status: {
    Pending: 'Pending',
    Confirmed: 'Confirmed',
    Approved: 'Approved',
    Completed: 'Completed',
    Cancelled: 'Cancelled'
  }

  enum communication: {
    email: 1,
    sms: 2,
    whatsapp: 4
  }

  def update_status
    return unless start_time.past? && !%w[Completed Canceled].include?(status)

    self.status = 'Completed'
    save
  end

  def set_communication_methods(methods)
    integer_value = methods.sum { |method| Appointment.communications[method] }
    self.communication_preferences = integer_value.to_s
  end

  def communication_enabled?(method)
    (communication_preferences.to_i & Appointment.communications[method]).positive?
  end

  def communication_preferences_hash
    {
      email: communication_enabled?(:email),
      sms: communication_enabled?(:sms),
      whatsapp: communication_enabled?(:whatsapp)
    }
  end

  private

  def set_initial_status
    if start_time.future?
      self.status ||= 'Pending'
    elsif start_time.past? && end_time.future?
      self.status ||= 'Completed'
    end
  end
end
