# frozen_string_literal: true
class Power
  include Consul::Power

  attr_reader :guid, :ministry, :person_id

  def initialize(guid, ministry)
    raise(Consul::Error, 'GUID required') unless guid.present?
    raise(Consul::Error, 'ministry required') unless ministry.present?
    @guid = guid
    @person_id = Person.gr_id_for_key_guid(guid)
    @ministry = ministry
  end

  power :profiles do
    V1::UserUpdatedPerson.all
  end
end
