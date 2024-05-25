class InvoicesController < ApplicationController
  # skip_before_action :authenticate_request

  def index
    @invoices = model.includes(:patient, invoice_items: :service).all
    render json: @invoices.map { |invoice| serialize_invoice(invoice) }
  end

  def create
    @invoice = Invoice.new

    @invoice.patient_id = params[:patient_id]
    @invoice.notes = params[:notes]
    @invoice.total = params[:total]
    @invoice.tax_rate = params[:tax_rate]
    @invoice.discount = params[:discount]
    @invoice.subtotal = params[:subtotal]
    @invoice.start_date = params[:start_date]
    @invoice.end_date = params[:end_date]

    if @invoice.save
      if params[:items]
        items = params[:items]
        items.map do |item|
          InvoiceItem.create(invoice_id: @invoice.id, quantity: item[:quantity], service_id: item[:service_id])
        end
      end

      @transaction = Transaction.new
      @transaction.amount = params[:total]
      @transaction.patient_id = params[:patient_id]
      @transaction.status = 'Pending'
      @transaction.payment_method = 'Insurance'

      if @transaction.save
        render json: { status: 'success', message: 'Transaction successfully added.', data: @transaction },
               status: :created
      else
        render json: { status: 'error', message: 'Failed to create transaction.', errors: @transaction.errors.full_messages },
               status: :unprocessable_entity
      end
    else

      render json: { status: 'error', message: 'Failed to create invoice.', errors: @invoice.errors.full_messages },
             status: :unprocessable_entity
    end
  end

  private

  def model
    @model ||= @current_user.admin? ? Invoice : Invoice.joins(:patient).where(patients: { user_id: @current_user.id })
  end

  def serialize_invoice(invoice)
    {
      id: invoice.id,
      to: serialize_patient(invoice.patient),
      total: invoice.total,
      subtotal: invoice.subtotal,
      discount: invoice.discount,
      tax: invoice.tax_rate,
      notes: invoice.notes,
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
      price: (invoice_item.service.price),
      quantity: invoice_item.quantity,
      description: invoice_item.service.description
    }
  end
end
