# frozen_string_literal: true
module V1
  class PeopleController < BaseController
    include Consul::Controller
    before_action :authenticate_request

    # Current Power must be defined before powers
    current_power do
      Power.new(current_user.key_guid, ministry)
    end

    power :profiles, as: :profile_scope

    def index
      if Power.current.admin?
        refresh_profiles if bool_value(params[:refresh])
        load_profiles
        render_profiles
      else
        params[:id] = Power.current.person_id
        load_profile
        render_profile or render_not_found
      end
    end

    def show
      refresh_profile if bool_value(params[:refresh])
      load_profile
      render_profile or render_not_found
    end

    def create
      # Create will update existing profile by params[:person_id]
      load_profile
      if build_profile
        render_profile
      else
        render_errors
      end
    end

    def update
      render_error('Invalid person_id') and return unless load_profile
      if build_profile
        render_profile
      else
        render_errors
      end
    end

    def destroy
    end

    private

    def ministry
      @ministry ||= Ministry.for_gr_id(params[:ministry_id])
    end

    def build_profile
      gr_id = params[:id] || params[:person_id]
      return nil unless gr_id.present?
      @profile ||= profile_scope.new(gr_id: gr_id)
      @profile.attributes = profile_params
      @profile.save
      @profile.reload
    rescue RestClient::BadRequest, RestClient::InternalServerError
      # after_save must raise error to force ROLLBACK, we need to catch it here
      false
    end

    def load_profiles
      @profiles ||= profile_scope
    end

    def load_profile
      gr_id = params[:id] || params[:person_id]
      return nil unless gr_id.present?
      @profile ||= profile_scope.find_by(gr_id: gr_id)
    end

    def render_profiles
      render json: @profiles, status: :ok, each_serializer: V1::ProfileSerializer
    end

    def render_profile
      render json: @profile, status: :ok, serializer: V1::ProfileSerializer unless @profile.blank?
    end

    def render_errors
      render json: @profile.errors.messages, status: :bad_request
    end

    def refresh_profiles
      Person.refresh_from_gr(ministry)
    end

    def refresh_profile
      Person.for_gr_id(params[:id], ministry, true)
    end

    def profile_params
      permitted_params = params.permit(*Person::PERMITTED_ATTRIBUTES)
      permitted_params[:ministry] = ministry
      permitted_params[:assignments_attributes] =
        params.permit(assignments: [Assignment::PERMITTED_ATTRIBUTES])[:assignments]
      permitted_params[:employment_attributes] = params.permit(*Employment::PERMITTED_ATTRIBUTES)
      permitted_params[:email_addresses_attributes] = [params.permit(:email)]
      permitted_params
    end
  end
end
