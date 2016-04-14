# frozen_string_literal: true
class Power
  include Consul::Power

  attr_reader :guid, :ministry, :person_id, :role

  def initialize(guid, ministry)
    raise(Consul::Error, 'GUID required') unless guid.present?
    raise(Consul::Error, 'ministry required') unless ministry.present?
    @guid = guid
    @person_id = Person.gr_id_for_key_guid(guid)
    @ministry = ministry
    @role = UserRole.find_by(key_guid: guid, ministry: ministry.gr_id)
  end

  power :profiles do
    if admin?
      V1::UserUpdatedPerson.where(ministry: ministry)
    else
      V1::UserUpdatedPerson.where(ministry: ministry, gr_id: person_id)
    end
  end

  def admin?
    role.try(:admin?)
  end
end
