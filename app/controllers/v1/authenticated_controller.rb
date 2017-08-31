# frozen_string_literal: true
module V1
  class AuthenticatedController < BaseController
    include Consul::Controller
    before_action :authenticate_request

    current_power do
      Power.new(current_user&.key_guid)
    end
  end
end
