class DashboardsController < ApplicationController
  # skip_before_action :authenticate_request
  def statistics
    start_date = Time.zone.now.beginning_of_year.to_date
    end_date = Time.zone.now.end_of_year.to_date

    render json: [
      format_dashboard_data(1, 'Total Patients', 'TbUsers', ['#66B5A3', '#66B5A3', '#66B5A3'],
                            aggregate_patient_data(Patient, start_date, end_date)),
      format_dashboard_data(2, 'Appointments', 'TbCalendar', ['#F9C851', '#F9C851', '#F9C851'],
                            aggregate_appointment_data(Appointment, start_date, end_date)),
      format_dashboard_data(3, 'Total Earnings', 'MdOutlineAttachMoney', ['#FF3B30', '#FF3B30', '#FF3B30'],
                            aggregate_earning_data(Invoice, start_date, end_date, :total))
    ]
  end

  def earnings
    start_date = Date.today.beginning_of_year
    end_date = Date.today.end_of_year

    model = @current_user.admin? ? Invoice : Invoice.joins(:patient).where(patients: { user_id: @current_user.id })

    earnings_by_month = model.where(created_at: start_date..end_date)
                             .group_by_month(:created_at, format: '%B')
                             .sum(:total)

    # Ensure all months are represented in the data
    monthly_totals = (1..12).map do |month|
      month_name = Date.new(Date.today.year, month, 1).strftime('%B')
      earnings_by_month[month_name].to_i || 0
    end

    render json: monthly_totals
  end

  private

  def aggregate_patient_data(model, start_date, end_date, sum_column = nil)
    model = @current_user.admin? ? model : model.where(user_id: @current_user.id)
    data = model.group_by_month(:created_at, range: start_date..end_date, series: true)
    data = sum_column ? data.sum(sum_column) : data.count
    months_range = generate_full_year_months(start_date, end_date)
    months_range.map { |month| data[month] || 0 }
  end

  def aggregate_appointment_data(model, start_date, end_date, sum_column = nil)
    model = @current_user.admin? ? model : model.joins(:patient).where(patients: { user_id: @current_user.id })
    data = model.group_by_month(:created_at, range: start_date..end_date, series: true)
    data = sum_column ? data.sum(sum_column) : data.count
    months_range = generate_full_year_months(start_date, end_date)
    months_range.map { |month| data[month] || 0 }
  end

  def aggregate_earning_data(model, start_date, end_date, sum_column = nil)
    model = @current_user.admin? ? model : model.joins(:patient).where(patients: { user_id: @current_user.id })
    data = model.group_by_month(:created_at, range: start_date..end_date, series: true)
    data = sum_column ? data.sum(sum_column) : data.count
    months_range = generate_full_year_months(start_date, end_date)
    months_range.map { |month| data[month] || 0 }
  end

  def generate_full_year_months(start_date, end_date)
    (start_date.beginning_of_year..end_date).select { |date| date.day == 1 }
  end

  def format_dashboard_data(id, title, icon, color, data)
    {
      id:,
      title:,
      icon:,
      value: title == 'Total Earnings' ? data.compact.sum : data.compact.sum,
      percent: calculate_percentage_change(data),
      color:,
      datas: data
    }
  end

  def calculate_percentage_change(data)
    data = data.compact
    return 0 if data.size < 2 || data[-2].zero?

    ((data.last - data[-2]) / data[-2].to_f * 100).round(2)
  end
end
