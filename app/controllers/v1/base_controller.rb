# frozen_string_literal: true
module V1
  class BaseController < ApplicationController
    include CruAuthLib::AccessTokenProtectedConcern
    include Consul::Controller

    rescue_from Consul::Powerless, with: :render_consul_powerless

    before_action :authenticate_request

    current_power do
      request_power
    end

    protected

    def request_power
      Power.new(current_user&.key_guid)
    end

    def render_consul_powerless(exception)
      render_error(exception.message, status: :unauthorized)
    end

    def current_user
      @access_token
    end

    def render_error(message, options = {})
      render(
        json: ApiError.new(message: message),
        status: options[:status] || :bad_request,
        serializer: V1::ApiErrorSerializer
      )
    end

    def render_not_found
      render_error 'Not Found', status: :not_found
    end

    def bool_value(value)
      ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
    end
  end
end
