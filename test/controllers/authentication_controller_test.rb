require "test_helper"

class AuthenticationControllerTest < ActionDispatch::IntegrationTest
  # --- Register tests ---

  test "register with valid data returns token, user_id, message and created status" do
    post api_auth_register_url, params: {
      user: {
        email: "newuser@example.com",
        password: "password123",
        first_name: "John",
        last_name: "Doe"
      }
    }, as: :json

    assert_response :created
    json_response = JSON.parse(response.body)
    assert json_response['token'].present?
    assert json_response['user_id'].present?
    assert_equal 'User created successfully', json_response['message']
  end

  test "register creates a new user in database" do
    assert_difference 'User.count', 1 do
      post api_auth_register_url, params: {
        user: {
          email: "another@example.com",
          password: "password123",
          first_name: "Jane",
          last_name: "Smith"
        }
      }, as: :json
    end
  end

  test "register with missing email returns unprocessable entity" do
    post api_auth_register_url, params: {
      user: {
        password: "password123",
        first_name: "John",
        last_name: "Doe"
      }
    }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert json_response['error'].present?
  end

  test "register with short password returns unprocessable entity" do
    post api_auth_register_url, params: {
      user: {
        email: "test@example.com",
        password: "short",
        first_name: "John",
        last_name: "Doe"
      }
    }, as: :json

    assert_response :unprocessable_content
  end

  test "register with duplicate email returns unprocessable entity" do
    post api_auth_register_url, params: {
      user: {
        email: users(:one).email,
        password: "password123",
        first_name: "John",
        last_name: "Doe"
      }
    }, as: :json

    assert_response :unprocessable_content
    json_response = JSON.parse(response.body)
    assert_includes json_response['error'], "Email has already been taken"
  end

  # --- Login tests ---

  test "login with valid credentials returns token and user_id" do
    post api_auth_login_url, params: {
      user: {
        email: users(:one).email,
        password: "password123"
      }
    }, as: :json

    assert_response :ok
    json_response = JSON.parse(response.body)
    assert json_response['token'].present?
    assert_equal users(:one).id, json_response['user_id']
  end

  test "login with wrong password returns unauthorized" do
    post api_auth_login_url, params: {
      user: {
        email: users(:one).email,
        password: "wrongpassword"
      }
    }, as: :json

    assert_response :unauthorized
    json_response = JSON.parse(response.body)
    assert_equal "Invalid email or password", json_response['error']
  end

  test "login with non-existent email returns unauthorized" do
    post api_auth_login_url, params: {
      user: {
        email: "nonexistent@example.com",
        password: "password123"
      }
    }, as: :json

    assert_response :unauthorized
  end

  test "login token contains correct user_id" do
    post api_auth_login_url, params: {
      user: {
        email: users(:one).email,
        password: "password123"
      }
    }, as: :json

    json_response = JSON.parse(response.body)
    decoded = JwtService.decode(json_response['token'])

    assert_equal users(:one).id, decoded['user_id']
  end
end
