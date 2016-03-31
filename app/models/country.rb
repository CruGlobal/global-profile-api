# frozen_string_literal: true
class Country < ActiveRecord::Base
  DEFAULT_GR_PARAMS = { entity_type: 'iso_country', levels: 0, fields: 'name,iso3_code' }.freeze

  class << self
    def refresh_from_gr
      all_iso_codes = []
      gr_client.get_all_pages(DEFAULT_GR_PARAMS) do |entity|
        country = create_or_update_from_entity(entity['iso_country'])
        all_iso_codes << country.iso_code if country.present?
      end
      where.not(iso_code: all_iso_codes).delete_all
      all
    end

    private

    def gr_client
      GlobalRegistryClient.new.entities
    end

    def create_or_update_from_entity(entity)
      country = find_or_initialize_by(iso_code: entity['iso3_code'])
      country.update(name: entity['name'])
      country
    end
  end
end
