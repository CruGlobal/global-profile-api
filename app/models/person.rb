# frozen_string_literal: true
class Person < ActiveRecord::Base
  DEFAULT_GR_PARAMS = { entity_type: 'person',
                        fields: 'first_name,last_name,preferred_name,email_address.email,email_address.primary,'\
                                'gender,birth_date,marital_status,language,authentication.key_guid,scope,is_secure,'\
                                'ministry:relationship,country_of_residence,email_address.location' }.freeze

  PERMITTED_ATTRIBUTES = [:key_guid, :key_username, :first_name, :last_name, :preferred_name, :gender,
                          :birth_date, :marital_status, :is_secure, :approved, :country_of_residence,
                          language: []].freeze

  enum gender: { 'Male' => 0, 'Female' => 1 }
  enum marital_status: { 'Single' => 0, 'Married' => 1, 'Engaged' => 2, 'Separated' => 3, 'Divorced' => 4,
                         'Widowed' => 5 }

  belongs_to :ministry

  has_many :assignments, dependent: :destroy
  has_one :employment, dependent: :destroy
  has_many :email_addresses, dependent: :destroy

  def email_address
    email_addresses.order(primary: :desc, updated_at: :desc).limit(1).first
  end

  class << self
    # Reloads all people from Global Registry
    def refresh_from_gr(ministry)
      gr_client(ministry)
        .entities
        .get_all_pages(DEFAULT_GR_PARAMS.merge('filters[owned_by]' => ministry.gr_system_permalink)) do |entity|
        create_or_update_from_entity(entity['person'], ministry)
      end if ministry.present?
    end

    def for_gr_id(gr_id, ministry, refresh = false)
      return unless gr_id.present? && ministry.present?
      found_person = find_by(gr_id: gr_id, ministry: ministry)
      return found_person if found_person.present? && !refresh
      create_or_update_from_gr_id_for_ministry(gr_id, ministry)
    end

    # Find person_id from key_guid with fallback to Global Registry
    def gr_id_for_key_guid(guid)
      return unless guid.present?
      person = find_or_initialize_by(key_guid: guid)
      return person.gr_id if person.gr_id.present?
      gr_id = gr_client.entity.get(entity_type: 'person', fields: 'id', 'filters[authentication][key_guid]' => guid)
                &.dig('entities', 0, 'person', 'id')
      person.update(gr_id: gr_id) if gr_id.present?
      person&.gr_id
    end

    private

    def gr_client(ministry = nil)
      return ministry.gr_ministry_client if ministry.present?
      GlobalRegistryClient.new
    end

    def create_or_update_from_gr_id_for_ministry(gr_id, ministry)
      gr_client(ministry)
        &.entity.find(gr_id, DEFAULT_GR_PARAMS.merge('filters[owned_by]' => ministry.gr_system_permalink))
    end

    def create_or_update_from_entity(entity, ministry)
      person = find_or_initialize_by(gr_id: entity['id'])
      person.update(first_name: entity['first_name'], last_name: entity['last_name'], gender: entity['gender'],
                    preferred_name: entity['preferred_name'], birth_date: entity['birth_date'],
                    marital_status: entity['marital_status'], country_of_residence: entity['country_of_residence'],
                    language: Array.wrap(entity['language']), key_guid: entity.dig('authentication', 'key_guid'),
                    is_secure: entity['is_secure'], ministry: ministry)
      person.assignments = create_or_update_assignments_from_entity(entity)
      person.employment = create_or_update_employment_from_entity(entity)
      person.email_addresses = create_or_update_email_from_entity(entity)
      person
    end

    def create_or_update_assignments_from_entity(entity)
      Array.wrap(entity['ministry:relationship']).select { |r| r['ministry_of_service'] }.map do |relationship|
        Assignment.create_or_update_from_relationship(relationship)
      end.compact
    end

    def create_or_update_employment_from_entity(entity)
      # We currently only care about a single employment relationship, take the last
      relationship = Array.wrap(entity['ministry:relationship']).select { |r| r['ministry_of_employment'] }.last
      Employment.create_or_update_from_relationship(relationship) if relationship
    end

    def create_or_update_email_from_entity(entity)
      Array.wrap(entity['email_address']).map do |email_address|
        EmailAddress.create_or_update_from_entity(email_address)
      end.compact
    end
  end
end