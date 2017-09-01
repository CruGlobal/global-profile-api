# frozen_string_literal: true
module V1
  class UserRolesController < AuthenticatedController
    power :superadmin

    def create
      render_error('Invalid Ministry Code') and return unless load_ministry
      if add_admin
        render_admin
      else
        render_error('Adding admin failed', status: :internal_server_error)
      end
    end

    def destroy
      render_error('Invalid Ministry Code') and return unless load_ministry
      if remove_admin
        render_admin
      else
        render_error('Admin not found', status: :not_found)
      end
    end

    private

    def load_ministry
      @ministry ||= Ministry.find_by(min_code: min_code)
    end

    def min_code
      params[:ministry] || params[:min_code]
    end

    def add_admin
      @admin = @ministry.add_admin(params[:admin])
    end

    def remove_admin
      @admin = @ministry.remove_admin(params[:admin])
    end

    def render_admin
      render json: @admin.person, status: :ok, serializer: V1::BasicProfileSerializer unless @admin.blank?
    end
  end
end
