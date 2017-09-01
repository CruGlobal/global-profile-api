# frozen_string_literal: true
module V1
  class MinistriesController < AuthenticatedController
    power :superadmin, only: :update

    def index
      refresh_ministries if bool_value(params[:refresh])
      filter_ministries
      render_ministries
    end

    def update
      ministry = Ministry.find_by(min_code: params[:id])
      render_not_found and return if ministry.nil?
      ministry.activate_site
      success_message = "Ministry site activated for #{ministry.name}"
      render status: 200, json: { success: success_message }
    end

    private

    def filter_ministries
      @ministries = Ministry.all.includes(:area) # Prefetch areas
      filter_inactive unless bool_value(params[:show_inactive])
      filter_profile_only if bool_value(params[:global_profile_only])
      @ministries = @ministries.order(name: :asc)
    end

    def filter_inactive
      @ministries = @ministries.where(active: true)
    end

    def filter_profile_only
      @ministries = @ministries.where.not(gp_key: nil)
    end

    def render_ministries
      render json: @ministries, status: :ok, each_serializer: V1::MinistrySerializer
    end

    def refresh_ministries
      Ministry.refresh_from_gr
    end
  end
end
