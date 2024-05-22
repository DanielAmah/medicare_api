# app/models/invoice_item.rb
class InvoiceItem < ApplicationRecord
  belongs_to :invoice
  belongs_to :service

  validates  :quantity, presence: true
  validates  :quantity, numericality: true
end
