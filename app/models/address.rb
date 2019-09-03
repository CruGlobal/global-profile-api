# frozen_string_literal: true

class Address < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:line1, :line2, :city, :state, :postal_code, :country].freeze

  def as_gr_entity
    entity = {}
    PERMITTED_ATTRIBUTES.each { |k| entity[k] = send(k) }
    entity.merge(client_integration_id: id).compact
  end
end
