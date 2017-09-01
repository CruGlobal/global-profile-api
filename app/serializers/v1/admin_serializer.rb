# frozen_string_literal: true
module V1
  class AdminSerializer < ActiveModel::Serializer
    attributes :key_guid,
               :first_name,
               :last_name
  end
end
