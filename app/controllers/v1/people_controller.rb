# frozen_string_literal: true
module V1
  class PeopleController < AuthenticatedController
    power :profiles, as: :profile_scope, context: :ministry

    def index
      if Power.current.admin?
        # refresh_profiles if bool_value(params[:refresh])
        load_profiles
        render_profiles
      else
        params[:id] = Power.current.person_id
        load_profile
        render_profile or render_not_found
      end
    end

    def show
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
      load_profile
      @profile.destroy
    end

    private

    def ministry
      @ministry ||= Ministry.for_gr_id(params[:ministry_id])
    end

    def gr_id
      params[:id] || params[:person_id]
    end

    def build_profile
      @profile ||= profile_scope.new
      @profile.attributes = profile_params
      @profile.set_spouse_from_attributes if @profile.respond_to? :set_spouse_from_attributes
      @profile.reload if @profile.save
    rescue RestClient::BadRequest, RestClient::InternalServerError
      # after_save callback must raise error to force ROLLBACK, we need to catch it here
      false
    end

    def load_profiles
      @profiles ||= profile_scope
    end

    def load_profile
      @profile ||= profile_scope.find_by(gr_id: gr_id)
    end

    def render_profiles
      render json: @profiles, status: :ok, each_serializer: V1::BasicProfileSerializer
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

    def profile_params
      permitted_params = params.permit(*Person::PERMITTED_ATTRIBUTES, :key_username)
      permitted_params[:gr_id] = gr_id
      permitted_params[:ministry] = ministry
      permitted_params[:assignments_attributes] = assignments_nested_params
      permitted_params[:employment_attributes] = employment_nested_params
      permitted_params[:address_attributes] = address_nested_params
      permitted_params[:children_attributes] = children_nested_params
      permitted_params[:spouse_attributes] = spouse_nested_params
      permitted_params
    end

    def assignments_nested_params
      params.permit(assignments: Assignment::PERMITTED_ATTRIBUTES)[:assignments] if params.key?(:assignments)
    end

    def employment_nested_params
      params.permit(*Employment::PERMITTED_ATTRIBUTES)
    end

    def address_nested_params
      params.require(:address).permit(*Address::PERMITTED_ATTRIBUTES)
    rescue ActionController::ParameterMissing
      return nil
    end

    def children_nested_params
      params.permit(children: Child::PERMITTED_ATTRIBUTES)[:children] if params.key?(:children)
    end

    def spouse_nested_params
      params.require(:spouse).permit(*Spouse::PERMITTED_ATTRIBUTES)
    rescue ActionController::ParameterMissing
      return nil
    end
  end
end
