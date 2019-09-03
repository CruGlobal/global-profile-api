# frozen_string_literal: true

class Child < ApplicationRecord
  PERMITTED_ATTRIBUTES = [:first_name, :last_name, :birth_date, :id].freeze

  belongs_to :parent, class_name: "Person", foreign_key: "person_id", inverse_of: :children

  after_destroy :destroy_gr_entity, if: -> { gr_id.present? }

  def as_gr_entity
    {first_name: first_name, last_name: last_name, birth_date: birth_date.try(:strftime, "%Y-%m-%d"),
     client_integration_id: "#{parent.id}:#{id}",}.compact
  end

  def destroy_gr_entity
    parent.ministry.gr_ministry_client.entity.delete(gr_id)
  rescue RestClient::ResourceNotFound
    nil
  end
end
