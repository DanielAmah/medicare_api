class Transaction < ApplicationRecord
  belongs_to :patient

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :status, presence: true,
                     inclusion: { in: %w[Paid Pending Cancelled], message: '%<value>s is not a valid status' }
  validates :payment_method, presence: true,
                             inclusion: { in: %w[Cash CreditCard Insurance], message: '%<value>s is not a valid payment method' }
end
