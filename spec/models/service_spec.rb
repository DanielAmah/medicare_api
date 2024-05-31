require 'rails_helper'

RSpec.describe Service, type: :model do
  # Validations
  describe 'validations' do
    it 'is valid with valid attributes' do
      service = Service.new(price: 100, active: true)
      expect(service).to be_valid
    end

    it 'is not valid with a negative price' do
      service = Service.new(price: -1, active: true)
      expect(service).not_to be_valid
      expect(service.errors[:price]).to include('must be greater than or equal to 0')
    end

    it 'is valid with a price of zero' do
      service = Service.new(price: 0, active: true)
      expect(service).to be_valid
    end

    it 'is valid with active set to true or false' do
      active_service = Service.new(price: 50, active: true)
      inactive_service = Service.new(price: 50, active: false)
      expect(active_service).to be_valid
      expect(inactive_service).to be_valid
    end

    it 'is not valid without active being true or false' do
      service = Service.new(price: 50, active: nil)
      expect(service).not_to be_valid
      expect(service.errors[:active]).to include('is not included in the list')
    end
  end

  # Associations
  describe 'associations' do
    it 'has many appointments' do
      expect(Service.reflect_on_association(:appointments).macro).to eq(:has_many)
    end
  end

  # Scopes
  describe 'scopes' do
    describe '.active' do
      let!(:active_service) { create(:service, active: true) }
      let!(:inactive_service) { create(:service, active: false) }

      it 'includes services where active is true' do
        expect(Service.active).to include(active_service)
        expect(Service.active).not_to include(inactive_service)
      end
    end
  end
end
