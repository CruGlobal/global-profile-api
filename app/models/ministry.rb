# frozen_string_literal: true
class Ministry < ActiveRecord::Base
  DEFAULT_GR_PARAMS = { entity_type: 'ministry', ruleset: 'global_ministries', levels: 0,
                        fields: 'name,min_code,area:relationship,is_active' }.freeze
  GP_SYSTEM_PREFIX = ENV.fetch('GLOBAL_REGISTRY_ACCESS_TOKEN_PREFIX')

  belongs_to :area
  has_many :people
  has_many :user_roles, foreign_key: :ministry, class_name: 'UserRole', primary_key: :gr_id, inverse_of: :gr_ministry

  scope :with_gp_key, -> { where.not(gp_key: nil) }

  # Ministry specific GR client
  def gr_ministry_client
    return GlobalRegistryClient.new(access_token: gp_key) if gp_key.present?
    # Find or create system access token
    system_client = GlobalRegistryClient.new.systems
    access_token = nil
    begin
      # Lookup System
      access_token = system_client.find(gr_system_permalink)&.dig('system', 'access_token')
    rescue RestClient::BadRequest
      # Create System
      access_token = system_client.post({ system: { name: "Global Profile - #{min_code}" } },
                                        params: { full_response: 'true' })&.dig('system', 'access_token')
    end
    update(gp_key: access_token) if access_token.present?
    GlobalRegistryClient.new(access_token: gp_key) if gp_key.present?
  end

  def gr_system_permalink
    "#{GP_SYSTEM_PREFIX}#{min_code.downcase.tr(' ', '_')}"
  end

  def copy_admin_roles_to(other_ministry)
    return if other_ministry.blank?
    admin_role = UserRole.roles[:admin]
    user_roles.where(role: admin_role).find_each do |my_user_role|
      other_ministry.user_roles.find_or_create_by!(key_guid: my_user_role.key_guid, role: admin_role)
    end
  end

  def activate_site
    gr_ministry_client unless gp_key.present?
  end

  def add_admin(email_or_guid)
    if is_email(email_or_guid)
      add_admin_by_email(email_or_guid)
    else
      add_admin_by_key_guid(email_or_guid)
    end
  end

  def add_admin_by_email(email)
    guid = TheKey::UserAttributes.new(email: email).cas_attributes['theKeyGuid']
    add_admin_by_key_guid(guid)
  end

  def add_admin_by_key_guid(guid)
    return if UserRole.exists?(key_guid: guid.downcase, ministry: gr_id)
    admin_role = UserRole.roles[:admin]
    UserRole.create(key_guid: guid.downcase, ministry: gr_id, role: admin_role)
  end

  def remove_admin(email_or_guid)
    if is_email(email_or_guid)
      remove_admin_by_email(email_or_guid)
    else
      remove_admin_by_key_guid(email_or_guid)
    end
  end

  def remove_admin_by_email(email)
    guid = TheKey::UserAttributes.new(email: email).cas_attributes['theKeyGuid']
    remove_admin_by_key_guid(guid)
  end

  def remove_admin_by_key_guid(guid)
    role = UserRole.find_by(key_guid: guid.downcase, ministry: gr_id, role: UserRole.roles[:admin])
    return if role.nil?
    role.destroy
  end

  private

  def is_email(email)
    email =~ /@/
  end

  class << self
    def refresh_from_gr
      all_min_codes = []
      gr_client.entities.get_all_pages(DEFAULT_GR_PARAMS) do |entity|
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
      GlobalRegistryClient.new
    end

    def create_from_gr_for_min_code(min_code)
      entity = gr_entity_for_min_code(min_code)
      create_or_update_from_entity(entity)
    end

    def create_from_gr_for_id(gr_id)
      entity = gr_client.entities.find(gr_id, DEFAULT_GR_PARAMS)['entity']['ministry']
      create_or_update_from_entity(entity)
    end

    def gr_entity_for_min_code(min_code)
      response = gr_client.entities.get(DEFAULT_GR_PARAMS.merge('filters[min_code]' => min_code))
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
