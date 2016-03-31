# frozen_string_literal: true
module AuthenticationHelpers
  def authenticate_guid(guid = nil)
    guid = SecureRandom.uuid.delete('-').upcase if guid.nil?
    access_token = CruLib::AccessToken.new(key_guid: guid)
    access_token.token
  end

  def authenticate_person(_person = nil)
    # TODO: implement
    nil
  end
end
