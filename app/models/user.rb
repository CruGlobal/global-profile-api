# frozen_string_literal: true
class User
  attr_accessor :access_token, :person_id, :admin_roles

  def initialize(access_token)
    self.access_token = access_token
    self.person_id = Person.gr_id_for_key_guid(access_token.key_guid)
    self.admin_roles = UserRole.where(key_guid: access_token.key_guid,
                                      role: UserRole.roles[:admin]).distinct.pluck(:ministry)
  end
end
