class Service < ApplicationRecord
  has_many :appointments

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }

  scope :active, -> { where(active: true) }
end
