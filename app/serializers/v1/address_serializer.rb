# frozen_string_literal: true

module V1
  class AddressSerializer < ActiveModel::Serializer
    attributes :line1,
               :line1,
               :line1,
               :city,
               :state,
               :postal_code,
               :country
  end
end
