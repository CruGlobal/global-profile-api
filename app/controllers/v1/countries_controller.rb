# frozen_string_literal: true
module V1
  class CountriesController < BaseController
    before_action :authenticate_request

    def index
      refresh_countries if bool_value(params[:refresh])
      load_countries
      render_countries
    end

    private

    def load_countries
      @countries = Country.all.order(name: :asc)
    end

    def render_countries
      render json: @countries, status: :ok, each_serializer: V1::CountrySerializer
    end

    def refresh_countries
      Country.refresh_from_gr
    end
  end
end
