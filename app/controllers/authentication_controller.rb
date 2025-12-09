# Handles user registration and login.
class AuthenticationController < ApplicationController
  skip_before_action :authenticate_user, only: [:register, :login]

  # POST /register - Creates a new user and returns JWT token.
  def register
    user = User.new(user_params)
    if user.save
      token = JwtService.encode({ user_id: user.id })
      render json: { token: token }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :unprocessable_content
    end
  end

  # POST /login - Authenticates user and returns JWT token.
  def login
    user = User.find_by(email: user_params[:email])
    if user&.authenticate(user_params[:password])
      token = JwtService.encode({ user_id: user.id })
      render json: { token: token }, status: :ok
    else 
      render json: { errors: 'Invalid Credentials' }, status: :unauthorized
    end
  end

  private 

  def user_params
    params.require(:user).permit(:email, :password, :first_name, :last_name)
  end
end
