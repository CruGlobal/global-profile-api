# frozen_string_literal: true
class Person < ActiveRecord::Base # rubocop:disable Metrics/ClassLength
  GR_FIELDS_PARAM = %w(first_name last_name preferred_name gender birth_date marital_status marriage_date language
                       is_secure authentication.key_guid email_address.* address.* phone_number.* children.*
                       ministry:relationship wife:relationship husband:relationship).freeze

  DEFAULT_GR_PARAMS = { entity_type: 'person', levels: 0, fields: GR_FIELDS_PARAM.join(',') }.freeze

  PERMITTED_ATTRIBUTES = [:key_guid, :key_username, :first_name, :last_name, :preferred_name, :gender, :birth_date,
                          :marital_status, :marriage_date, :is_secure, :approved, :phone_number, :skype_id, :email,
                          language: []].freeze

  enum gender: { 'Male' => 0, 'Female' => 1 }
  enum marital_status: { 'Single' => 0, 'Married' => 1, 'Engaged' => 2, 'Separated' => 3, 'Divorced' => 4,
                         'Widowed' => 5, 'Married to non-staff' => 6 }

  belongs_to :ministry
  belongs_to :spouse, foreign_key: :spouse_id, class_name: 'Person', inverse_of: :spouse, autosave: true
  has_many :assignments, dependent: :destroy
  has_one :employment, dependent: :destroy
  has_one :address, dependent: :destroy
  has_many :children, dependent: :destroy, inverse_of: :parent, autosave: true
  has_many :user_roles, foreign_key: :key_guid, class_name: 'UserRole', primary_key: :key_guid, inverse_of: :person

  after_destroy :destroy_gr_entity, if: 'gr_id.present?'
  before_save :update_gr_spouse_relationship, if: 'spouse_id_changed?'

  # private

  def push_to_gr
    # POST entity, this will create or update existing
    entity = ministry.gr_ministry_client.entity.post(entity: as_gr_entity)&.dig('entity', 'person')
    update_child_gr_ids_from_entity(entity)
    # PUT relationships, this will create or update existing, relationships not allowed in a POST.
    entity = ministry.gr_ministry_client.entity.put(entity['id'], { entity: entity_relationships },
                                                    params: { full_response: true })&.dig('entity', 'person')
    update_gr_ids_from_entity(entity)
  rescue RestClient::BadRequest, RestClient::InternalServerError => error
    errors.add :base, error.message
    raise error
  end

  def as_gr_entity # rubocop:disable Metrics/AbcSize
    entity = { last_name: last_name, first_name: first_name, preferred_name: preferred_name, gender: gender,
               birth_date: birth_date.try(:strftime, '%Y-%m-%d'), language: language, skype_id: skype_id,
               marital_status: marital_status == 'Married to non-staff' ? 'Married' : marital_status,
               marriage_date: marriage_date.try(:strftime, '%Y-%m-%d'),
               is_secure: is_secure?, authentication: { key_guid: key_guid }, client_integration_id: id }
    entity[:email_address] = { email: email, primary: true, client_integration_id: id } if email.present?
    entity[:address] = address.as_gr_entity if address.present?
    entity[:phone_number] = { number: phone_number, primary: true, client_integration_id: id } if phone_number.present?
    entity[:child] = children.map(&:as_gr_entity) if children.present?
    entity.deep_compact!
    { person: entity }
  end

  def entity_relationships
    entity = { client_integration_id: id }
    entity.merge!(spouse_entity_relationship) if spouse.present?
    entity['ministry:relationship'] = entity_ministry_relationships
    entity.deep_compact!
    { person: entity }
  end

  def entity_ministry_relationships
    relationships = assignments.map(&:as_gr_relationship)
    relationships << employment.as_gr_relationship if employment.present?
    relationships
  end

  def spouse_entity_relationship
    relationship_name = gender == 'Female' ? 'husband:relationship' : 'wife:relationship'
    # Create client_integration_id using numerical order of person.id and spouse.id
    # This will generate the same cid regardless of which side POSTs data to the GR
    client_integration_id = if id < spouse.id
                              "global_profile:spouse:#{id}:#{spouse.id}"
                            else
                              "global_profile:spouse:#{spouse.id}:#{id}"
                            end
    entity = { person: spouse.gr_id, client_integration_id: client_integration_id }
    { relationship_name => entity }
  end

  def update_child_gr_ids_from_entity(entity)
    Array.wrap(entity['child']).each do |child_entity|
      begin
        child = children.find(cid_from_entity(child_entity))
        child.update_column(:gr_id, child_entity['id'])
      rescue ActiveRecord::RecordNotFound
        next
      end
    end
  end

  def update_gr_ids_from_entity(entity)
    # Use update_column to skip callbacks and just update the database
    update_column(:gr_id, entity['id'])
    update_ministry_relationship_ids_from_entity(entity) if entity['ministry:relationship'].present?
    update_spouse_relationship_id_from_entity(entity)
  end

  def update_ministry_relationship_ids_from_entity(entity)
    Array.wrap(entity['ministry:relationship']).each do |rel_entity|
      begin
        if rel_entity['ministry_of_service']
          relationship = assignments.find(cid_from_entity(rel_entity))
          relationship.update_column(:gr_id, rel_entity['relationship_entity_id']) if relationship.present?
        elsif rel_entity['ministry_of_employment']
          if employment.id.to_s == cid_from_entity(rel_entity)
            employment.update_column(:gr_id, rel_entity['relationship_entity_id'])
          end
        end
      rescue ActiveRecord::RecordNotFound
        next
      end
    end
  end

  def update_spouse_relationship_id_from_entity(entity)
    rel_entity = Array.wrap(entity['husband:relationship'] || entity['wife:relationship']).first
    update_column(:spouse_rel_id, rel_entity&.dig('relationship_entity_id'))
    spouse.update_column(:spouse_rel_id, rel_entity&.dig('relationship_entity_id')) if spouse.present?
  end

  def cid_from_entity(entity)
    return entity['client_integration_id']['value'] if entity['client_integration_id'].is_a? Hash
    # Split CID on ':' and use last part
    entity['client_integration_id'].split(':').last
  end

  def destroy_gr_entity
    # Person table also holds people for authentication, they do no not have a ministry_id
    return unless ministry.present?
    # First delete the spouse relationship if it exists
    ministry.gr_ministry_client.entity.delete(spouse_rel_id) if spouse.present?
    # Then delete the person, assignment/employment relationships are handled through dependent: destroy
    ministry.gr_ministry_client.entity.delete(gr_id)
  rescue RestClient::ResourceNotFound
    nil
  end

  def update_gr_spouse_relationship
    return unless ministry.present?
    # We need to delete the old GR spouse relationship if the spouse has changed
    # If spouse_rel_id is missing, we can't delete
    # If previous spouse_id was blank, no need to delete
    return if spouse_rel_id.blank? || spouse_id_was.blank?
    ministry.gr_ministry_client.entity.delete(spouse_rel_id)
  rescue RestClient::ResourceNotFound
    nil
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
    def gr_id_for_key_guid(guid, ministry = nil)
      return unless guid.present?
      person = Person.find_or_initialize_by(key_guid: guid, ministry: ministry)
      return person.gr_id if person.gr_id.present?
      entity = gr_client.entity.get(entity_type: 'person',
                                    fields: 'id,first_name,last_name', 'filters[authentication][key_guid]' => guid)
                 &.dig('entities', 0, 'person')
      person.update(gr_id: entity['id'],
                    first_name: entity['first_name'],
                    last_name: entity['last_name']) if entity.present?
      person&.gr_id
    end

    protected

    def gr_client(ministry = nil)
      return ministry.gr_ministry_client if ministry.present?
      GlobalRegistryClient.new
    end

    def create_or_update_from_gr_id_for_ministry(gr_id, ministry)
      entity = gr_client(ministry)
                 &.entity.find(gr_id, DEFAULT_GR_PARAMS.merge('filters[owned_by]' => ministry.gr_system_permalink))
                 &.dig('entity', 'person')
      create_or_update_from_entity(entity, ministry) if entity.present?
    rescue RestClient::ResourceNotFound
      nil
    end

    def create_or_update_from_entity(entity, ministry) # rubocop:disable Metrics/AbcSize
      person = find_or_initialize_by(gr_id: entity['id'], ministry: ministry)
      person.update(first_name: entity['first_name'], last_name: entity['last_name'], gender: entity['gender'],
                    preferred_name: entity['preferred_name'], birth_date: entity['birth_date'],
                    marital_status: entity['marital_status'], marriage_date: entity['marriage_date'],
                    language: Array.wrap(entity['language']), key_guid: entity.dig('authentication', 'key_guid'),
                    is_secure: entity['is_secure'].nil? ? false : entity['is_secure'],
                    email: Array.wrap(entity['email_address']).first&.dig('email'),
                    skype_id: entity['skype_id'])
      person.assignments = create_or_update_assignments_from_entity(entity)
      person.employment = create_or_update_employment_from_entity(entity)
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
  end
end
