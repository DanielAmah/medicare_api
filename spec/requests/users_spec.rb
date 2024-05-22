# spec/requests/users_spec.rb
require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /users' do
    let(:valid_attributes) do
      { name: 'John Doe', email: 'john.doe@example.com', password: 'secure123', password_confirmation: 'secure123',
        role: 'admin', title: 'Dr.' }
    end

    let(:invalid_attributes) do
      { name: '', email: 'invalid_email', password: '123', password_confirmation: '1234', role: 'unknown',
        title: 'King' }
    end

    context 'with valid parameters' do
      it 'creates a new User' do
        expect do
          post users_path, params: { user: valid_attributes }
        end.to change(User, :count).by(1)
      end

      it 'returns a created status' do
        post users_path, params: { user: valid_attributes }
        expect(response).to have_http_status(:created)
        expect(response.body).to include('User successfully registered.')
      end
    end

    context 'with invalid parameters' do
      it 'does not create a new User' do
        expect do
          post users_path, params: { user: invalid_attributes }
        end.to change(User, :count).by(0)
      end

      it 'returns an unprocessable entity status' do
        post users_path, params: { user: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include('User registration failed.')
      end
    end
  end
end
