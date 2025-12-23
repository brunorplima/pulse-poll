# Base controller for API v1 endpoints.
module Api
  module V1
    class BaseController < ApplicationController
      rescue_from ActionController::ParameterMissing, with: :bad_request
      rescue_from ActiveRecord::RecordNotFound, with: :not_found
      rescue_from ActiveRecord::RecordInvalid, with: :unprocessable_content
      rescue_from ApiError::Unauthorized, with: :unauthorized
      rescue_from ApiError::Forbidden, with: :forbidden

      private

      def bad_request(error)
        render json: { error: error.message }, status: :bad_request
      end

      def not_found(error)
        render json: { error: error.message }, status: :not_found
      end

      def unprocessable_content(error)
        render json: { error: error.record.errors.full_messages.first }, status: :unprocessable_content
      end

      def unauthorized(error)
        render json: { error: error.message }, status: :unauthorized
      end

      def forbidden(error)
        render json: { error: error.message }, status: :forbidden
      end
    end
  end
end
