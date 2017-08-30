# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::User_Roles', type: :request do
  let(:json) { JSON.parse(response.body) }
  describe 'POST /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        post '/v1/user_roles'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'adds an admin role' do
        ministry = instance_double('Ministry', min_code: 'GUE')
        role = instance_double('UserRole')
        allow(role).to receive_message_chain(:person, :first_name).and_return('John')
        allow(role).to receive_message_chain(:person, :last_name).and_return('Doe')
        allow(ministry).to receive(:add_admin) { role }
        allow(Ministry).to receive(:find_by) { ministry }

        post '/v1/user_roles', {admin: 'John.Doe@cru.org', ministry: 'GUE'}, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(ministry).to have_received(:add_admin)
      end

      it 'returns 404 for invalid ministry' do
        post '/v1/user_roles/', {admin: 'John.Doe@cru.org', ministry: 'DNE'}, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).not_to be_success
        expect(response).to have_http_status 404
      end
    end
  end

end
