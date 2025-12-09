# == Schema Information
#
# Table name: users
#
#  id              :integer          not null, primary key
#  email           :string
#  first_name      :string
#  last_name       :string
#  password_digest :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
require "test_helper"

# User.new(email: 'new.user@email.com', password: 'password123', first_name: 'Mark', last_name: 'Hensson')

class UserTest < ActiveSupport::TestCase

  test "should save when all data is valid" do
    user = User.new(email: 'Mark.h@email.com', password: 'password123', first_name: 'Mark', last_name: 'Hensson')
    assert user.save
  end

  # --- Email validations ---

  test "should not save without email" do
    user = User.new(password: 'password123', first_name: 'Mark', last_name: 'Hensson')
    assert_not user.save
    assert_equal user.errors[:email].count, 2
    assert_includes user.errors[:email], "can't be blank"
    assert_includes user.errors[:email], 'is invalid'
  end

  test "should not save with invalid email" do
    user = User.new(email: 'new.useremail.com', password: 'password123')
    assert_not user.save
    assert_equal user.errors[:email].count, 1
    assert_includes user.errors[:email], 'is invalid'
  end

  test "should not save with repeated email" do
    user = User.new(email: 'john.doe@email.com', password: 'password123')
    assert_not user.save
    assert_equal user.errors[:email].count, 1
    assert_includes user.errors[:email], 'has already been taken'
  end

  # --- Password validations ---

  test "should not save with short password" do
    user = User.new(email: 'new.useremail.com', password: 'passwor')
    assert_not user.save
    assert_equal user.errors[:password].count, 1
    assert_includes user.errors[:password], 'is too short (minimum is 8 characters)'
  end

  # --- first_name validations ---

  test "should not save without first_name" do
    user = User.new(email: 'new.user@email.com', password: 'password123', last_name: 'Hensson')
    assert_not user.save
    assert_equal user.errors[:first_name].count, 1
    assert_includes user.errors[:first_name], "can't be blank"
  end

  # --- last_name validations ---

  test "should not save without last_name" do
    user = User.new(email: 'new.user@email.com', password: 'password123', first_name: 'Hensson')
    assert_not user.save
    assert_equal user.errors[:last_name].count, 1
    assert_includes user.errors[:last_name], "can't be blank"
  end
end
