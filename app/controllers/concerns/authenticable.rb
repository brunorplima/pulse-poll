# Concern for JWT-based authentication in API controllers.
# Include in ApplicationController to protect endpoints.
#
# Sets @current_user when authentication succeeds.
# Returns 401 Unauthorized with error message when authentication fails.
module Authenticable
  extend ActiveSupport::Concern

  # Authenticates the request by validating the JWT token.
  # Expects Authorization header in format: "Bearer <token>"
  #
  # @return [void]
  def authenticate_user
    auth_header = request.headers['Authorization']
    if auth_header.blank?
      render json: { error: 'Missing token' }, status: :unauthorized
      return
    end
    token = auth_header.split(' ').last

    payload = handle_payload(token)
    return if payload.blank?

    user_id = payload['user_id']
    user = User.find_by(id: user_id)

    if user.blank?
      render json: { error: 'User does not exist' }, status: :unauthorized
      return
    end

    @current_user = user
  end

  private

  # Decodes JWT token and handles errors.
  #
  # @param token [String] The JWT token to decode
  # @return [Hash, nil] The decoded payload, or nil if decoding fails
  def handle_payload(token)
    JwtService.decode(token)
  rescue JWT::VerificationError
    render json: { error: 'Signature verification failed. Token is invalid.' }, status: :unauthorized
    nil
  rescue JWT::ExpiredSignature
    render json: { error: 'Signature verification failed. Token is expired.' }, status: :unauthorized
    nil
  rescue JWT::DecodeError, StandardError => e
    render json: { error: e.message }, status: :unauthorized
    nil
  end
end
