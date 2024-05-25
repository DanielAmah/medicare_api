class User < ApplicationRecord
  has_secure_password
  # has_many :patients, dependent: :destroy
  # has_many :appointments, dependent: :destroy

  has_many :appointments, dependent: :destroy
  has_many :patients, through: :appointments

  has_one_attached :profile_image, dependent: :destroy

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :secondary_email, format: { with: URI::MailTo::EMAIL_REGEXP }, allow_blank: true
  validates :password_digest, presence: true
  validates :role, presence: true, inclusion: { in: %w[doctor admin], message: '%<value>s is not a valid role' }
  validates :title, inclusion: { in: %w[Dr. Mr. Mrs. Ms.], message: '%<value>s is not a valid title' }

  def profile_image_url
    return unless profile_image.attached?

    Rails.application.routes.url_helpers.rails_blob_url(profile_image,
                                                        host: Rails.application.config.action_controller.default_url_options[:host])
  end

  def patient_permission?(action)
    # Assuming permissions: 1 for read, 2 for edit, 4 for create, 8 for delete
    # Check if user has permission for the given action
    (patient_permissions & action) == action
  end

  def admin?
    role == 'admin'
  end

  def doctor?
    role == 'doctor'
  end

  PERMISSIONS = {
    read: 1,
    edit: 2,
    create: 4,
    delete: 8
  }

  def self.permissions
    PERMISSIONS
  end
end
