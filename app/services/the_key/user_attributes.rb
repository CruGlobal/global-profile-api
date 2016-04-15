# frozen_string_literal: true
module TheKey
  class UserAttributes
    def initialize(email:)
      @email = email
    end

    def cas_attributes
      response = RestClient.get(
        ENV['CAS_URL'] + "/cas/api/#{ENV['CAS_ACCESS_TOKEN']}/user/attributes?email=#{@email}",
        accept: :json
      )
      JSON.parse(response)
      # Sample output
      # {"relayGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
      #  "ssoGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
      #  "firstName"=>"Joshua",
      #  "lastName"=>"Starcher",
      #  "theKeyGuid"=>"F167605D-94A4-7121-2A58-8D0F2CA6E026",
      #  "email"=>"josh.starcher@cru.org"}
    end
  end
end
