require "test_helper"

class JwtServiceTest < ActiveSupport::TestCase
  test "encode returns a JWT token string" do
    payload = { user_id: 1 }
    token = JwtService.encode(payload)

    assert_instance_of String, token
    assert_match(/^[\w-]+\.[\w-]+\.[\w-]+$/, token)
  end

  test "decode returns the original payload" do
    payload = { user_id: 123 }
    token = JwtService.encode(payload)
    decoded = JwtService.decode(token)

    assert_equal 123, decoded['user_id']
  end

  test "decode includes expiration in payload" do
    payload = { user_id: 1 }
    token = JwtService.encode(payload)
    decoded = JwtService.decode(token)

    assert decoded['exp'].present?
    assert decoded['exp'] > Time.now.to_i
  end

  test "decode raises error for expired token" do
    payload = { user_id: 1 }
    token = JwtService.encode(payload, 1.second.ago)

    assert_raises JWT::ExpiredSignature do
      JwtService.decode(token)
    end
  end

  test "decode raises error for invalid token" do
    assert_raises JWT::DecodeError do
      JwtService.decode("invalid.token.here")
    end
  end

  test "decode raises error for tampered token" do
    payload = { user_id: 1 }
    token = JwtService.encode(payload)
    tampered_token = token + "tampered"

    assert_raises JWT::DecodeError do
      JwtService.decode(tampered_token)
    end
  end
end

