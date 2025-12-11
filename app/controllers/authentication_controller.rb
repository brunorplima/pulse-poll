# Handles user registration and login.
class AuthenticationController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login]

  # POST /api/auth/register - Creates a new user and returns JWT token.
  def register
    user = User.new(user_params)
    if user.save
      token = JwtService.encode({ user_id: user.id, token_version: user.token_version })
      render json: {
        message: 'User created successfully',
        user_id: user.id,
        token: token
      }, status: :created
    else
      render json: { error: user.errors.full_messages.first }, status: :unprocessable_content
    end
  end

  # POST /api/auth/login - Authenticates user and returns JWT token.
  def login
    user = User.find_by(email: user_params[:email])
    if user&.authenticate(user_params[:password])
      token = JwtService.encode({ user_id: user.id, token_version: user.token_version })
      render json: { token: token, user_id: user.id }, status: :ok
    else
      render json: { error: 'Invalid email or password' }, status: :unauthorized
    end
  end

  # POST /api/auth/logout - Logout authenticated user
  def logout
    current_user.increment!(:token_version)
    render json: { message: 'Logged out successfully' }, status: :ok
  end

  private

  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name)
  end
end
