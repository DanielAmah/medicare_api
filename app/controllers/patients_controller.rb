class PatientsController < ApplicationController
  skip_before_action :authenticate_request
  before_action :set_patient, only: %i[show destroy]

  def create
    @patient = Patient.new

    @patient.name = patient_params[:name]
    @patient.email = patient_params[:email]
    @patient.phone = patient_params[:phone]
    @patient.age = patient_params[:age]
    @patient.gender = patient_params[:gender]
    @patient.blood_type = patient_params[:type]
    @patient.profile_image.attach(patient_params[:profile_image])

    if @patient.save
      render json: { status: 'success', message: 'Patient successfully added.', data: @patient }, status: :created
    else
      render json: { status: 'error', message: 'Failed to create patient.', errors: @patient.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def index
    patients = Patient.includes(:appointments)
                      .order(created_at: :desc)

    render json: patients.map { |patient| format_patient(patient) }
  end

  def destroy
    @patient.destroy
    render json: { message: 'Patient deleted successfully' }, status: :ok
  end

  def show
    @appointments = @patient.appointments.includes(:user, :service).order('created_at DESC')
    @invoices = @patient.invoices.includes(:invoice_items).order('created_at DESC')
    @payments = @patient.transactions.order('created_at DESC')

    render json: {
      **patient_data(@patient),
      appointments: @appointments.map { |appointment| format_appointment(appointment) },
      invoices: @invoices.map { |invoice| serialize_invoice(invoice) },
      payments: @payments.map { |payment| format_transaction(payment) }
    }
  end

  def patient_dashboard_cards
    render json: [
      {
        id: 1,
        title: 'Today Patients',
        value: Patient.where(created_at: Time.zone.now.all_day).count.to_s,
        color: %w[bg-subMain text-subMain],
        icon: 'BiTime'
      },
      {
        id: 2,
        title: 'Monthly Patients',
        value: Patient.where(created_at: Time.zone.now.all_month).count.to_s,
        color: %w[bg-orange-500 text-orange-500],
        icon: 'BsCalendarMonth'
      },
      {
        id: 3,
        title: 'Yearly Patients',
        value: Patient.where(created_at: Time.zone.now.all_year).count.to_s,
        color: %w[bg-green-500 text-green-500],
        icon: 'MdOutlineCalendarMonth'
      }
    ]
  end

  def recent
    recent_patients = Patient.includes(:appointments)
                             .order(created_at: :desc)
                             .limit(5) # or any number you prefer

    render json: recent_patients.map { |patient| format_patient(patient) }
  end

  private

  def format_transaction(transaction)
    {
      id: transaction.id,
      user: format_user(transaction.patient, 'patient'),
      date: transaction.created_at.strftime('%b %d, %Y'),
      amount: (transaction.amount / 100),
      status: transaction.status,
      method: transaction.payment_method,
      doctor: format_user(transaction.patient.user, 'doctor')
    }
  end

  def serialize_invoice(invoice)
    {
      id: invoice.id,
      to: serialize_patient(invoice.patient),
      total: invoice.total,
      createdDate: invoice.created_at.strftime('%d/%m/%Y'),
      dueDate: invoice.end_date.strftime('%d/%m/%Y'),
      items: invoice.invoice_items.map { |item| serialize_invoice_item(item) }
    }
  end

  def serialize_patient(patient)
    {
      id: patient.id,
      title: patient.name,
      image: patient.profile_image_url,
      admin: false,
      email: patient.email,
      phone: patient.phone,
      age: patient.age,
      gender: patient.gender,
      blood: patient.blood_type,
      totalAppointments: patient.appointments.count,
      date: patient.created_at.strftime('%d %b %Y')
    }
  end

  def serialize_invoice_item(invoice_item)
    {
      id: invoice_item.id,
      name: invoice_item.service.name,
      price: invoice_item.service.price,
      description: invoice_item.service.description
    }
  end

  def set_patient
    @patient = Patient.find(params[:id])
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
        price: appointment.service.price,
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

  def format_patient(patient)

    {
      id: patient.id,
      title: patient.name,
      image: patient.profile_image_url, # Ensure this method exists in your Patient model
      admin: false,
      email: patient.email,
      phone: patient.phone,
      age: patient.age,
      gender: patient.gender,
      blood: patient.blood_type,
      totalAppointments: patient.appointments.count,
      date: patient.created_at.strftime('%d %b %Y'),
      timeOfJoining: patient.created_at.strftime('%I:%M %p')
    }
  end

  def patient_data(patient)
    {
      id: patient.id,
      name: patient.name,
      image: patient.profile_image_url,
      email: patient.email,
      phone: patient.phone,
      created_at: patient.created_at.strftime('%B %d, %Y')
    }
  end

  def serialize_appointment(appointment)
    {
      id: appointment.id,
      date: appointment.start_time.strftime('%b %d, %Y'),
      doctor: appointment.user.name,
      status: appointment.status,
      time: "#{appointment.start_time.strftime('%I:%M %p')} - #{appointment.end_time.strftime('%I:%M %p')}"
      # action: 'edit_link_or_something' # Depends on what action means in your system
    }
  end

  def serialize_payment(payment)
    {
      id: payment.id,
      amount: payment.amount,
      status: payment.status,
      payment_method: payment.payment_method,
      date: payment.created_at.strftime('%b %d, %Y')
    }
  end

  def patient_params
    params.require(:patient).permit(:name, :phone, :email, :age, :gender, :blood_type, :profile_image)
  end
end
