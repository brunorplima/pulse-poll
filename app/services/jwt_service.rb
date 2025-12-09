# Service for encoding and decoding JSON Web Tokens (JWT).
# Used for stateless authentication in the API.
class JwtService
  SECRET_KEY = Rails.application.secret_key_base

  # Encodes a payload into a JWT token.
  #
  # @param payload [Hash] The data to encode (e.g., { user_id: 1 })
  # @param exp [Time] Token expiration time (default: 1 hour from now)
  # @return [String] The encoded JWT token
  def self.encode(payload, exp = 1.hours.from_now)
    payload[:exp] = exp.to_i
    JWT.encode(payload, SECRET_KEY, 'HS256')
  end

  # Decodes a JWT token and returns the payload.
  #
  # @param token [String] The JWT token to decode
  # @return [Hash] The decoded payload with string keys
  # @raise [JWT::ExpiredSignature] If the token has expired
  # @raise [JWT::VerificationError] If the signature is invalid
  # @raise [JWT::DecodeError] If the token is malformed
  def self.decode(token)
    JWT.decode(token, SECRET_KEY, true, { algorithm: 'HS256' }).first
  end
end