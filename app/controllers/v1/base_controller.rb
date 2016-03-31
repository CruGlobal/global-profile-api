# frozen_string_literal: true
module V1
  class BaseController < ApplicationController
    include CruLib::AccessTokenProtectedConcern

    protected

    def current_user
      return nil unless @access_token
      # TODO: implement
      nil
    end

    def render_error(message, options = {})
      render(
        json: ApiError.new(message: message),
        status: options[:status] || :bad_request,
        serializer: V1::ApiErrorSerializer
      )
    end

    def bool_value(value)
      ActiveRecord::Type::Boolean.new.type_cast_from_user(value)
    end
  end
end
