class TransactionsController < ApplicationController
  skip_before_action :authenticate_request

  def summary
    today = Date.today
    this_year = today.beginning_of_year..today.end_of_year
    this_month = today.beginning_of_month..today.end_of_month

    data = [
      {
        id: 1,
        title: 'Today Payments',
        value: (Transaction.where(created_at: today.all_day).sum(:amount).to_i / 100).to_s(:delimited),
        color: %w[bg-subMain text-subMain],
        icon: 'BiTime'
      },
      {
        id: 2,
        title: 'Monthly Payments',
        value: (Transaction.where(created_at: this_month).sum(:amount).to_i / 100).to_s(:delimited),
        color: %w[bg-orange-500 text-orange-500],
        icon: 'BsCalendarMonth'
      },
      {
        id: 3,
        title: 'Yearly Payments',
        value: (Transaction.where(created_at: this_year).sum(:amount).to_i / 100).to_s(:delimited),
        color: %w[bg-green-500 text-green-500],
        icon: 'MdOutlineCalendarMonth'
      }
    ]

    render json: data
  end

  def recent
    recent_transactions = Transaction.includes(patient: %i[user])
                                     .order(created_at: :desc)
                                     .limit(10) # or any number you prefer
    total_today = Transaction.where('created_at >= ?', Date.today.beginning_of_day)
                             .sum(:amount).to_i

    render json: {
      transactions: recent_transactions.map { |transaction| format_transaction(transaction) },
      total_today:
    }
  end

  private

  def format_transaction(transaction)
    {
      id: transaction.id,
      user: format_user(transaction.patient, 'patient'),
      date: transaction.created_at.strftime('%b %d, %Y'),
      amount: (transaction.amount / 100).to_i,
      status: transaction.status,
      method: transaction.payment_method,
      doctor: format_user(transaction.patient.user, 'doctor')
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
end
