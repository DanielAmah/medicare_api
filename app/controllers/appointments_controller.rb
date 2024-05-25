class AppointmentsController < ApplicationController
  # skip_before_action :authenticate_request

  def index
    appointments = model.includes(:user, :service).all
    render json: appointments.map { |appointment| format_appointment(appointment) }
  end

  def today
    today = Date.current
    appointments_today = model.includes(:user, :service)
                              .where('start_time >= ? AND start_time <= ?', today.beginning_of_day, today.end_of_day)
    render json: appointments_today.map { |appointment| format_appointment(appointment) }
  end

  def create
    appointment = Appointment.new(appointment_params)
    appointment.user_id = @current_user.id
    appointment.communication_preferences = generate_communication_bitmask(params[:communication_preferences])

    if appointment.save
      render json: appointment, status: :created
    else
      render json: appointment.errors, status: :unprocessable_entity
    end
  end

  def total
    appointments = model.includes(:user, :patient).all
    formatted_appointments = appointments.map do |appointment|
      format_appointment(appointment)
    end
    render json: formatted_appointments
  end

  private

  def model
    @model ||= @current_user.admin? ? Appointment : Appointment.joins(:patient).where(patients: { user_id: @current_user.id })
  end

  def appointment_params
    params.require(:appointment).permit(:patient_id, :user_id, :service_id, :start_time, :end_time, :status, :purpose,
                                        :description, communication_preferences: {})
  end

  def generate_communication_bitmask(preferences)
    bitmask = 0
    bitmask |= Appointment.communications[:email] if preferences[:email]
    bitmask |= Appointment.communications[:sms] if preferences[:sms]
    bitmask |= Appointment.communications[:whatsapp] if preferences[:whatsapp]
    bitmask
  end

  def format_appointment(appointment)
    {
      id: appointment.id,
      start: appointment.start_time.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      end: appointment.end_time.utc.strftime('%Y-%m-%dT%H:%M:%S.000Z'),
      color: '#FC8181',
      title: appointment.patient.name,
      message: appointment.message,
      service: {
        id: appointment.service.id,
        name: appointment.service.name,
        price: (appointment.service.price),
        date: appointment.service.created_at.strftime('%d %B, %Y'),
        status: appointment.service.active?
      },
      shareData: appointment.communication_preferences_hash,
      time: time_relative_to_now(appointment.start_time),
      user: format_user(appointment.patient, 'patient'),
      from: appointment.start_time.strftime('%I:%M %p'),
      to: appointment.end_time.strftime('%I:%M %p'),
      hours: ((appointment.end_time - appointment.start_time) / 1.hour).round,
      status: appointment.status,
      doctor: format_user(appointment.user, 'doctor'),
      date: appointment.created_at.strftime('%b %d, %Y')
    }
  end

  def format_user(user, type)
    {
      id: user.id,
      title: user.name,
      image: user.profile_image_url,
      admin: type == 'patient' ? false : user.admin?,
      email: user.email,
      phone: user.phone,
      age: type == 'patient' ? user.age : nil,
      gender: type == 'patient' ? user.gender : nil,
      blood: type == 'patient' ? user.blood_type : nil,
      totalAppointments: user.appointments.count,
      date: user.created_at.strftime('%b %d, %Y')
    }
  end

  def time_relative_to_now(time)
    seconds_diff = (time - Time.current).to_i.abs
    hours = seconds_diff / 3600
    if time.future?
      "#{hours} hrs later"
    else
      "#{hours} hrs ago"
    end
  end

  def format_datetime(datetime)
    datetime.strftime('%Y-%m-%dT%H:%M:%S.000Z')
  end
end
