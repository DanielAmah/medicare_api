class UsersController < ApplicationController
  skip_before_action :authenticate_request, only: %i[create create_doctor]
  before_action :set_doctor, only: %i[show destroy update]

  def index
    doctors = User.where(role: 'doctor')

    formatted_doctors = doctors.map do |doctor|
      {
        id: doctor.id,
        user: format_user(doctor, 'doctor'),
        title: doctor.title
      }
    end

    if @current_user.admin?
      render json: formatted_doctors
    else
      render json: []
    end
  end

  def destroy
    @user.destroy
    render json: { message: 'Doctor deleted successfully' }, status: :ok
  end

  def show
    render json: {
      **user_data,
      patients: @user.patients.map { |patient| serialize_patient(patient) },
      appointments: @user.appointments.map { |appointment| format_appointment(appointment) },
      payments: Transaction.joins(patient: :user).where(users: { id: @user.id }).map do |transaction|
                  format_transaction(transaction)
                end,
      invoices: Invoice.includes(patient: :user,
                                 invoice_items: :service).where(patients: { user_id: @user.id }).map do |invoice|
                  serialize_invoice(invoice)
                end
    }
  end

  def update
    @user.name = user_params[:name]
    @user.email = user_params[:email]
    @user.title = 'Dr.'
    @user.phone = user_params[:phone]
    @user.profile_image.attach(user_params[:profile_image]) if user_params[:profile_image]
    if @user.save
      render json: { status: 'success', message: 'Doctor successfully updated!', data: @user }, status: :created
    else
      render json: { status: 'error', message: 'Failed to update doctor.', errors: @user.errors.full_messages },
             status: :unprocessable_entity
    end
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

  def serialize_invoice_item(invoice_item)
    {
      id: invoice_item.id,
      name: invoice_item.service.name,
      price: invoice_item.service.price,
      description: invoice_item.service.description
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

  def format_transaction(transaction)
    {
      id: transaction.id,
      user: format_user(transaction.patient, 'patient'),
      date: transaction.created_at.strftime('%b %d, %Y'),
      amount: transaction.amount,
      status: transaction.status,
      method: transaction.payment_method,
      doctor: format_user(transaction.patient.user, 'doctor')
    }
  end

  def index
    doctors = User.where(role: 'doctor')

    formatted_doctors = doctors.map do |doctor|
      {
        id: doctor.id,
        user: format_user(doctor, 'doctor'),
        title: doctor.title
      }
    end

    render json: formatted_doctors
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: { status: 'success', message: 'User successfully registered.', data: user }, status: :created
    else
      render json: { status: 'error', message: 'User registration failed.', errors: user.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  def create_doctor
    @doctor = User.new

    @doctor.name = user_params[:name]
    @doctor.email = user_params[:email]
    @doctor.password = params[:password]
    @doctor.password_confirmation = params[:password]
    @doctor.phone = user_params[:phone]
    @doctor.role = 'doctor' # Set role as 'doctor'
    @doctor.title = user_params[:title]

    @doctor.profile_image.attach(user_params[:profile_image]) if user_params[:profile_image]
    if user_params[:access]
      @doctor.patient_permissions = calculate_permissions(user_params[:access][:patient])
      @doctor.appointment_permissions = calculate_permissions(user_params[:access][:appointment])
      @doctor.invoice_permissions = calculate_permissions(user_params[:access][:invoices])
      @doctor.payment_permissions = calculate_permissions(user_params[:access][:payments])
    end

    if @doctor.save
      render json: { status: 'success', message: 'Doctor successfully added.', data: @doctor }, status: :created
    else
      render json: { status: 'error', message: 'Failed to create doctor.', errors: @doctor.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

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

  def format_datetime(datetime)
    datetime.strftime('%Y-%m-%dT%H:%M:%S.000Z')
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

  def user_data
    {
      id: @user.id,
      name: @user.name,
      email: @user.email,
      title: @user.title,
      phone: @user.phone,
      profile_image_url: @user.profile_image_url
    }
  end

  def set_doctor
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :title, :phone, :password, :password_confirmation,
                                 :profile_image, access: {})
  end

  def calculate_permissions(access_hash)
    access_hash.keys.reduce(0) do |sum, key|
      sum + (access_hash[key] == '1' ? User.permissions[key.to_sym] : 0)
    end
  end

  # def format_user(doctor)
  #   {
  #     id: doctor.id,
  #     title: doctor.name,
  #     image: doctor.profile_image_url,
  #     admin: doctor.admin?, # Assuming there's a method to determine if the user is an admin
  #     email: doctor.email,
  #     phone: doctor.phone,
  #     # age: doctor.age, # Ensure age is stored and updated as needed
  #     # gender: doctor.gender, # Ensure gender is part of your user model
  #     # blood: doctor.blood_type, # Ensure blood type is part of your user model
  #     totalAppointments: doctor.appointments.count,
  #     date: doctor.created_at.strftime('%b %d, %Y')
  #   }
  # end
end
