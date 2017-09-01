# frozen_string_literal: true
class Power
  include Consul::Power

  attr_reader :guid, :ministry, :person_id, :role, :superadmin

  def initialize(guid)
    @guid = guid
    @ministry = nil
    @role = nil
    @person_id = Person.gr_id_for_key_guid(guid) unless guid.nil?
    @superadmin = UserRole.superadmin?(guid) unless guid.nil?
  end

  power :profiles do |min|
    raise(Consul::Error, 'guid required') unless @guid.present?
    raise(Consul::Error, 'ministry required') unless min.present?
    @ministry ||= min
    @role ||= UserRole.find_by(key_guid: @guid, ministry: ministry.gr_id)
    if admin?
      V1::UserUpdatedPerson.where(ministry: ministry)
    else
      V1::UserUpdatedPerson.where(ministry: ministry, gr_id: person_id)
    end
  end

  power :superadmin do
    superadmin?
  end

  def admin?
    superadmin? || role.try(:admin?)
  end

  def superadmin?
    @superadmin
  end
end
