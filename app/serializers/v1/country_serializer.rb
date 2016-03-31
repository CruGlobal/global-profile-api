# frozen_string_literal: true
module V1
  class CountrySerializer < ActiveModel::Serializer
    attribute :iso_code, key: :iso3
    attribute :name
  end
end
