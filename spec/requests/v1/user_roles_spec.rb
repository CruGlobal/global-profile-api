# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::User_Roles', type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user_key_guid) { SecureRandom.uuid }
  let(:user_gr_id) { SecureRandom.uuid }
  let(:ministry_gr_id) { SecureRandom.uuid }
  let(:authenticate) { authenticate_guid(user_key_guid) }
  let(:ministry) { create(:ministry, gr_id: ministry_gr_id) }
  let!(:user) { create(:person, key_guid: user_key_guid, gr_id: user_gr_id, ministry: ministry) }

  before :each do
    allow(Person).to receive(:gr_id_for_key_guid).and_return user_key_guid
  end

  describe 'POST /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        post '/v1/user_roles'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with HTTP 401 for non-superadmin' do
        ministry = instance_double('Ministry', min_code: 'GUE')
        role = instance_double('UserRole')
        allow(role).to receive_message_chain(:person, :first_name).and_return('John')
        allow(role).to receive_message_chain(:person, :last_name).and_return('Doe')
        allow(ministry).to receive(:add_admin) { role }
        allow(Ministry).to receive(:find_by) { ministry }
        post '/v1/user_roles',
             { admin: 'John.Doe@cru.org', ministry: 'GUE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end

      it 'adds an admin role' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE', gr_id: SecureRandom.uuid)
        admin_key_guid = SecureRandom.uuid
        admin_gr_id = SecureRandom.uuid
        create(:person, first_name: 'John', last_name: 'Doe', key_guid: admin_key_guid, gr_id: admin_gr_id)
        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(admin_roles).to eq 0

        post '/v1/user_roles',
             { admin: admin_key_guid, ministry: 'GUE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(admin_roles).to eq 1
        expect(response).to be_success
        expect(response).to have_http_status :ok
      end

      it 'returns 400 for invalid ministry' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        post '/v1/user_roles/',
             { admin: 'John.Doe@cru.org', ministry: 'DNE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end
    end
  end

  describe 'DELETE /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        delete '/v1/user_roles'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with HTTP 401 for non-superadmin' do
        ministry = instance_double('Ministry', min_code: 'GUE')
        role = instance_double('UserRole')
        allow(role).to receive_message_chain(:person, :first_name).and_return('John')
        allow(role).to receive_message_chain(:person, :last_name).and_return('Doe')
        allow(ministry).to receive(:add_admin) { role }
        allow(Ministry).to receive(:find_by) { ministry }
        post '/v1/user_roles',
             { admin: 'John.Doe@cru.org', ministry: 'GUE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end

      it 'removes an admin role' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE', gr_id: SecureRandom.uuid)
        admin_key_guid = SecureRandom.uuid
        admin_gr_id = SecureRandom.uuid
        admin = create(:person, first_name: 'John', last_name: 'Doe', key_guid: admin_key_guid, gr_id: admin_gr_id)
        ministry.add_admin(admin.key_guid)

        delete '/v1/user_roles',
               { admin: admin.key_guid, ministry: 'GUE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(admin_roles).to eq 0
      end

      it 'returns 400 for invalid ministry' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        delete '/v1/user_roles/',
               { admin: 'John.Doe@cru.org', ministry: 'DNE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end

      it 'returns 404 for invalid admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = instance_double('Ministry', min_code: 'GUE')
        allow(ministry).to receive(:remove_admin) { nil }
        allow(Ministry).to receive(:find_by) { ministry }

        delete '/v1/user_roles/',
               { admin: 'John.Doe@cru.org', ministry: 'DNE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status 404
      end
    end
  end
end
