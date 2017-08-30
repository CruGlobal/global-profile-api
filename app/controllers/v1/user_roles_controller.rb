# frozen_string_literal: true
module V1
  class UserRolesController < BaseController
    before_action :authenticate_request

    def create
      @ministry = Ministry.find_by(min_code: params[:ministry])
      render_not_found and return if @ministry.nil?
      add_admin
    end

    def destroy
      @ministry = Ministry.find_by(min_code: params[:ministry])
      render_not_found and return if @ministry.nil?
      remove_admin
    end

    private

    def add_admin
      admin = @ministry.add_admin(params[:admin])
      render status: 200, json: { success: add_success_message(admin) }
    end

    def remove_admin
      admin = @ministry.remove_admin(params[:admin])
      if admin.nil?
        render status: 404, json: { fail: remove_success_message(admin) }
      else
        render status: 200, json: { success: remove_success_message(admin) }
      end
    end

    def add_success_message(admin)
      action_message = admin.nil? ? 'Admin already exists for' : 'added as admin to'
      "#{admin&.person&.first_name} #{admin&.person&.last_name} #{action_message} #{@ministry.min_code}".strip
    end

    def remove_success_message(admin)
      action_message = admin.nil? ? 'Admin not found for' : 'removed from'
      "#{admin&.person&.first_name} #{admin&.person&.last_name} #{action_message} #{@ministry.min_code}".strip
    end
  end
end
