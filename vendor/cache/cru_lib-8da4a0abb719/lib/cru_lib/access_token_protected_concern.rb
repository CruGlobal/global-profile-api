module CruLib
  module AccessTokenProtectedConcern
    extend ActiveSupport::Concern

    protected

    def authenticate_request
      authenticate_token || render_unauthorized
    end

    def authenticate_token
      token = oauth_access_token_from_header
      return unless oauth_access_token_from_header
      @access_token = AccessToken.read(token)
    end

    # grabs access_token from header if one is present
    def oauth_access_token_from_header
      auth_header = request.env['HTTP_AUTHORIZATION'] || ''
      match = auth_header.match(/^Bearer\s(.*)/)
      return match[1] if match.present?
      false
    end

    def render_unauthorized
      headers['WWW-Authenticate'] = %{CAS realm="Application"}
      render_error('Bad token', status: 401)
    end
  end
end
