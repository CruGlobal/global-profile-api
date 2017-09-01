# frozen_string_literal: true
module V1
  class AuthenticatedController < BaseController
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
  end
end
