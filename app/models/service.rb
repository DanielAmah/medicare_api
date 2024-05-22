class Service < ApplicationRecord
  has_many :appointments

  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :active, inclusion: { in: [true, false] }

  # You could also add scopes or methods that use these new fields:
  scope :active, -> { where(active: true) }
end
