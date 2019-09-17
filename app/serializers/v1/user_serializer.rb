# frozen_string_literal: true

module V1
  class UserSerializer < ActiveModel::Serializer
    attributes :key_guid, :email, :person_id, :first_name, :last_name, :admin

    def key_guid
      object.access_token&.key_guid
    end

    def email
      object.access_token&.email
    end

    def first_name
      object.access_token&.first_name
    end

    def last_name
      object.access_token&.last_name
    end

    delegate :person_id, to: :object

    def admin
      object.admin_roles
    end
  end
end
