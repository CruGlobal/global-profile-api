# frozen_string_literal: true
module V1
  class UserRolesController < BaseController
    power :superadmin

    def index
      render_error('Invalid Ministry Code') and return unless load_ministry
      if load_admins
        render_admins
      else
        render_error('Loading admins failed', status: :internal_server_error)
      end
    end

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

    def load_admins
      @admins ||= admins_query
    end

    def admins_query
      Person.includes(:user_roles).where(user_roles: { role: UserRole.roles[:admin], ministry: load_ministry.gr_id })
    end

    def render_admins
      render json: @admins, status: :ok, each_serializer: V1::AdminSerializer
    end

    def load_ministry
      @ministry ||= Ministry.find_by(min_code: min_code)
    end

    def min_code
      params[:ministry] || params[:min_code]
    end

    def add_admin
      @admin = @ministry.add_admin(admin_identifier)
    end

    def remove_admin
      @admin = @ministry.remove_admin(admin_identifier)
    end

    def admin_identifier
      params[:admin_email] || params[:admin_guid] || params[:id]
    end

    def render_admin
      render json: @admin.person, status: :ok, serializer: V1::AdminSerializer unless @admin.blank?
    end
  end
end
