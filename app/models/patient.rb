class Patient < ApplicationRecord
  belongs_to :user, optional: true
  # has_many :appointments, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :users, through: :appointments

  has_many :transactions, dependent: :destroy
  has_many :invoices, dependent: :destroy

  has_one_attached :profile_image

  validates :name, presence: true
  validates :phone, presence: true, format: { with: /\A\+?\d{10,15}\z/, message: 'must be a valid phone number' }
  validates :age, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true
  validates :gender, inclusion: { in: %w[Male Female Other], message: '%<value>s is not a valid gender' },
                     allow_nil: true
  validates :blood_type,
            inclusion: { in: %w[A+ A- B+ B- AB+ AB- O+ O-], message: '%<value>s is not a valid blood type' }, allow_nil: true

  def profile_image_url
    Rails.application.routes.url_helpers.rails_blob_url(profile_image,
      host: Rails.application.config.action_controller.default_url_options[:host]) if profile_image.attached?
  end
end
