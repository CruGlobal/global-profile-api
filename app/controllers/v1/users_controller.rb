# frozen_string_literal: true
module V1
  class UsersController < BaseController
    before_action :authenticate_request

    def show
      load_user
      render_user
    end

    private

    def load_user
      @user = User.new(@access_token)
    end

    def render_user
      render json: @user, status: :ok, serializer: V1::UserSerializer
    end
  end
end
