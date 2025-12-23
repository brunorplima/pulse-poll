# Handles user registration and login.
module Api
  module V1
    class AuthenticationController < BaseController
      skip_before_action :authenticate_user, only: [:register, :login]

      # POST /api/v1/auth/register - Creates a new user and returns JWT token.
      def register
        user = User.new(user_params)
        user.save!
        token = JwtService.encode({ user_id: user.id, token_version: user.token_version })

        render json: {
          message: 'User created successfully',
          user_id: user.id,
          token: token
        }, status: :created
      end

      # POST /api/v1/auth/login - Authenticates user and returns JWT token.
      def login
        user = User.find_by(email: user_params[:email])
        if user&.authenticate(user_params[:password])
          token = JwtService.encode({ user_id: user.id, token_version: user.token_version })
          render json: { token: token, user_id: user.id }, status: :ok
        else
          raise ApiError::Unauthorized.new 'Invalid email or password'
        end
      end

      # POST /api/v1/auth/logout - Logout authenticated user
      def logout
        current_user.increment!(:token_version)
        render json: { message: 'Logged out successfully' }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :first_name, :last_name)
      end
    end
  end
end
