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
      render_error('Invalid Ministry Code') and return unless load_ministry
      if activate_ministry
        render_ministry
      else
        render_errors
      end
    end

    private

    def activate_ministry
      @ministry.activate_site
    end

    def load_ministry
      @ministry ||= Ministry.find_by(min_code: min_code)
    end

    def min_code
      params[:id] || params[:min_code]
    end

    def render_ministry
      render json: @ministry, status: :ok, serializer: V1::MinistrySerializer unless @ministry.blank?
    end

    def render_errors
      render json: @ministry.errors.messages, status: :bad_request
    end

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
