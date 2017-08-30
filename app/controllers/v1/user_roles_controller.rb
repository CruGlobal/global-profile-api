# frozen_string_literal: true
module V1
  class UserRolesController < BaseController
    before_action :authenticate_request

    def create
      @ministry = Ministry.find_by(min_code: params[:ministry])
      render_error_not_found and return if @ministry.nil?
      add_admin
    end

    private

    def add_admin
      admin = @ministry.add_admin(params[:admin])
      render status: 200, json: {success: success_message(admin)}
    end

    def render_error_not_found
      render status: 404, json: {error: "Ministry '#{ params[:ministry] }' not found"}
    end

    def success_message(admin)
      action_message = admin.nil? ? "Admin already exists for" : "added as admin to"
      return_message = "#{ admin&.person&.first_name } #{ admin&.person&.last_name } #{ action_message } #{@ministry.min_code}"
    end
  end
end
