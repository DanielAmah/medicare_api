require 'rails_helper'

RSpec.describe User, type: :model do
  # Setup a user for testing
  let!(:user) do
    User.create(name: 'John Doe', email: 'johndoe@example.com', password: 'securepassword',
                password_confirmation: 'securepassword', role: 'admin', title: 'Dr.')
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    it 'is not valid without a name' do
      user.name = nil
      expect(user).not_to be_valid
    end

    it 'is not valid without an email' do
      user.email = nil
      expect(user).not_to be_valid
    end

    it 'is not valid with a duplicate email' do
      duplicate_user = user.dup
      expect(duplicate_user).not_to be_valid
    end

    it 'is not valid with an invalid email format' do
      user.email = 'invalid-email'
      expect(user).not_to be_valid
    end

    it 'is valid with a blank secondary email' do
      user.secondary_email = ''
      expect(user).to be_valid
    end

    it 'is not valid with an invalid secondary email format' do
      user.secondary_email = 'invalid-email'
      expect(user).not_to be_valid
    end

    it 'is not valid without a password' do
      user.password_digest = nil
      expect(user).not_to be_valid
    end

    it "accepts only specified roles" do
      valid_role = User.new(name: "Test User", email: "test@example.com", password: 'securepassword', role: "admin", title: "Dr.")
      invalid_role = User.new(name: "Test User", email: "test@example.com", password: 'securepassword', role: "invalid_role", title: "Dr.")
      expect(valid_role).to be_valid
      expect(invalid_role).not_to be_valid
    end

    it "accepts only specified titles" do
      valid_title = User.new(name: "Test User", email: "test@example.com", password: 'securepassword', role: "admin", title: "Dr.")
      invalid_title = User.new(name: "Test User", email: "test@example.com", password: 'securepassword', role: "admin", title: "Lord")
      expect(valid_title).to be_valid
      expect(invalid_title).not_to be_valid
    end
  end

  describe '#profile_image_url' do
    it 'returns nil if no image is attached' do
      expect(user.profile_image_url).to be_nil
    end

    # You need to attach an image here using something like Active Storage's attach method if it's supposed to return something
  end

  describe '#patient_permission?' do
    it 'returns true if the user has specified permission' do
      user.patient_permissions = 1 # Assuming 1 is read permission
      expect(user.patient_permission?(1)).to be true
    end

    it 'returns false if the user does not have specified permission' do
      user.patient_permissions = 1 # Assuming 1 is read permission
      expect(user.patient_permission?(2)).to be_falsey
    end
  end
end
