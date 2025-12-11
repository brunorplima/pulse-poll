require "test_helper"

class AuthenticableTest < ActiveSupport::TestCase
  # Create a fake controller class to include the concern
  class FakeController
    include Authenticable

    attr_accessor :rendered_response, :rendered_status

    def request
      @request ||= OpenStruct.new(headers: {})
    end

    def render(json:, status:)
      @rendered_response = json
      @rendered_status = status
    end
  end

  setup do
    @controller = FakeController.new
  end

  # --- Missing/Empty token tests ---

  test "returns unauthorized when authorization header is missing" do
    @controller.request.headers['Authorization'] = nil
    @controller.authenticate_user

    assert_equal({ error: 'Missing token' }, @controller.rendered_response)
    assert_equal :unauthorized, @controller.rendered_status
  end

  test "returns unauthorized when authorization header is empty" do
    @controller.request.headers['Authorization'] = ""
    @controller.authenticate_user

    assert_equal({ error: 'Missing token' }, @controller.rendered_response)
    assert_equal :unauthorized, @controller.rendered_status
  end

  # --- Invalid token tests ---

  test "returns unauthorized when token is invalid" do
    @controller.request.headers['Authorization'] = "Bearer invalid.token.here"
    @controller.authenticate_user

    assert_equal :unauthorized, @controller.rendered_status
    assert @controller.rendered_response[:error].present?
  end

  test "returns unauthorized when token is tampered" do
    token = JwtService.encode({ user_id: users(:one).id })
    @controller.request.headers['Authorization'] = "Bearer #{token}tampered"
    @controller.authenticate_user

    assert_equal :unauthorized, @controller.rendered_status
  end

  # --- Expired token tests ---

  test "returns unauthorized when token is expired" do
    expired_token = JwtService.encode({ user_id: users(:one).id }, 1.second.ago)
    @controller.request.headers['Authorization'] = "Bearer #{expired_token}"
    @controller.authenticate_user

    assert_equal :unauthorized, @controller.rendered_status
    assert_match(/expired/i, @controller.rendered_response[:error])
  end

  # --- User not found tests ---

  test "returns unauthorized when user does not exist" do
    token = JwtService.encode({ user_id: 999999 })
    @controller.request.headers['Authorization'] = "Bearer #{token}"
    @controller.authenticate_user

    assert_equal({ error: 'User does not exist' }, @controller.rendered_response)
    assert_equal :unauthorized, @controller.rendered_status
  end

  # --- Successful authentication tests ---

  test "sets current_user with valid token" do
    user = users(:one)
    token = JwtService.encode({ user_id: user.id, token_version: user.token_version })
    @controller.request.headers['Authorization'] = "Bearer #{token}"

    @controller.authenticate_user

    assert_equal user, @controller.instance_variable_get(:@current_user)
  end

  test "does not render error with valid token" do
    user = users(:one)
    token = JwtService.encode({ user_id: user.id, token_version: user.token_version })
    @controller.request.headers['Authorization'] = "Bearer #{token}"

    @controller.authenticate_user

    assert_nil @controller.rendered_response
    assert_nil @controller.rendered_status
  end

  test "returns unauthorized when token_version does not match" do
    user = users(:one)
    token = JwtService.encode({ user_id: user.id, token_version: user.token_version + 1 })
    @controller.request.headers['Authorization'] = "Bearer #{token}"

    @controller.authenticate_user

    assert_equal({ error: 'Token has been revoked' }, @controller.rendered_response)
    assert_equal :unauthorized, @controller.rendered_status
  end

  test "returns unauthorized when token_version is missing from token" do
    user = users(:one)
    token = JwtService.encode({ user_id: user.id })
    @controller.request.headers['Authorization'] = "Bearer #{token}"

    @controller.authenticate_user

    assert_equal({ error: 'Token has been revoked' }, @controller.rendered_response)
    assert_equal :unauthorized, @controller.rendered_status
  end
end
