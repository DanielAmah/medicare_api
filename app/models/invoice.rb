# app/models/invoice.rb
class Invoice < ApplicationRecord
  belongs_to :patient
  has_many :invoice_items, dependent: :destroy

  validates :subtotal, :discount, :tax_rate, :total, presence: true
  validates :subtotal, :discount, :tax_rate, :total, numericality: true
end
