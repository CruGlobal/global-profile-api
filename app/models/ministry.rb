# frozen_string_literal: true
class Ministry < ActiveRecord::Base
  DEFAULT_GR_PARAMS = { entity_type: 'ministry', ruleset: 'global_ministries', levels: 0,
                        fields: 'name,min_code,area:relationship,is_active' }.freeze

  belongs_to :area

  class << self
    def refresh_from_gr
      all_min_codes = []
      gr_client.get_all_pages(DEFAULT_GR_PARAMS) do |entity|
        ministry = create_or_update_from_entity(entity['ministry'])
        all_min_codes << ministry.min_code if ministry.present?
      end
      where.not(min_code: all_min_codes).delete_all
      all
    end

    def for_gr_id(gr_id)
      return unless gr_id.present?
      found_ministry = find_by(gr_id: gr_id)
      return found_ministry if found_ministry.present?
      create_from_gr_for_id(gr_id)
    end

    def for_min_code(min_code)
      return unless min_code.present?
      found_ministry = find_by(min_code: min_code)
      return found_ministry if found_ministry.present?
      create_from_gr_for_min_code(min_code)
    end

    private

    def gr_client
      GlobalRegistryClient.new.entities
    end

    def create_from_gr_for_min_code(min_code)
      entity = gr_entity_for_min_code(min_code)
      create_or_update_from_entity(entity)
    end

    def create_from_gr_for_id(gr_id)
      entity = gr_client.find(gr_id, DEFAULT_GR_PARAMS)['entity']['ministry']
      create_or_update_from_entity(entity)
    end

    def gr_entity_for_min_code(min_code)
      response = gr_client.get(DEFAULT_GR_PARAMS.merge('filters[min_code]' => min_code))
      response['entities'].first['ministry']
    end

    def create_or_update_from_entity(entity)
      ministry = find_or_initialize_by(gr_id: entity['id'])
      ministry.area = area_from_entity(entity)
      ministry.update(name: entity['name'], min_code: entity['min_code'], active: entity['is_active'])
      ministry
    end

    def area_from_entity(entity)
      relationship = entity&.dig('area:relationship')
      area_gr_id = Array.wrap(relationship).first&.dig('area')
      return unless area_gr_id
      Area.for_gr_id(area_gr_id)
    end
  end
end
