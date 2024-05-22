require 'rails_helper'

RSpec.describe 'Sessions', type: :request do
  describe 'POST /login' do
    let!(:user) { create(:user) }

    context 'with valid credentials' do
      it 'authenticates the user and returns a token' do
        post login_path, params: { email: user.email, password: user.password }
        expect(response).to have_http_status(:ok)
        json_response = JSON.parse(response.body)
        expect(json_response['message']).to eq('Logged in successfully')
        expect(json_response).to have_key('token')
        expect(json_response).to have_key('exp')
      end
    end

    context 'with invalid credentials' do
      it 'fails to authenticate the user' do
        post login_path, params: { email: user.email, password: 'wrong_password' }
        expect(response).to have_http_status(:unauthorized)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid email or password')
      end
    end

    context 'with invalid password hash in database' do
      it 'handles an invalid hash error' do
        allow(User).to receive(:find_by).and_return(user)
        allow(user).to receive(:authenticate).and_raise(BCrypt::Errors::InvalidHash)

        post login_path, params: { email: user.email, password: 'whatever' }
        expect(response).to have_http_status(:internal_server_error)
        json_response = JSON.parse(response.body)
        expect(json_response['error']).to eq('Invalid password hash in database')
      end
    end
  end
end
