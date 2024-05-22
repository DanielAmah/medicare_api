class InvoicesController < ApplicationController
  skip_before_action :authenticate_request

  def index
    @invoices = Invoice.includes(:patient, invoice_items: :service).all
    render json: @invoices.map { |invoice| serialize_invoice(invoice) }
  end

  private

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
      price: (invoice_item.service.price / 100),
      description: invoice_item.service.description
    }
  end
end
