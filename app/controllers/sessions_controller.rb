require 'jwt'
class SessionsController < ApplicationController
  skip_before_action :authenticate_request
  def create
    user = User.find_by(email: params[:email])
    if user && user.authenticate(params[:password])
      token = JwtService.encode(user_id: user.id)

      render json: {
        message: 'Logged in successfully',
        token:,
        exp: 24.hours.from_now.to_i,
        is_admin: user.admin?,
        name: user.name,
        title: user.title,
        id: user.id,
        profile: user.profile_image_url
      }, status: :ok
    else
      # Authentication failed
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  rescue BCrypt::Errors::InvalidHash => e
    # Handle cases where the hash is invalid
    render json: { error: 'Invalid password hash in database' }, status: :internal_server_error
  end
end
