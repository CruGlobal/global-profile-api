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

  describe 'GET /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/user_roles'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end
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
             { admin_email: 'John.Doe@cru.org', ministry: 'GUE' },
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
             { admin_guid: admin_key_guid, ministry: 'GUE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(admin_roles).to eq 1
        expect(response).to be_success
        expect(response).to have_http_status :ok
      end

      it 'returns 400 for invalid ministry' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        post '/v1/user_roles/',
             { admin_email: 'John.Doe@cru.org', ministry: 'DNE' },
             'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end
    end
  end

  describe 'DELETE /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        delete '/v1/user_roles/test'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with HTTP 401 for non-superadmin' do
        delete '/v1/user_roles/test',
               { admin_email: 'John.Doe@cru.org', ministry: 'GUE' },
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

        delete "/v1/user_roles/#{admin.key_guid}",
               { ministry: 'GUE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(admin_roles).to eq 0
      end

      it 'returns 400 for invalid ministry' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        delete "/v1/user_roles/#{SecureRandom.uuid}",
               { ministry: 'DNE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end

      it 'returns 404 for invalid admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE', gr_id: SecureRandom.uuid)
        admin_key_guid = SecureRandom.uuid
        admin_gr_id = SecureRandom.uuid
        admin = create(:person, first_name: 'John', last_name: 'Doe', key_guid: admin_key_guid, gr_id: admin_gr_id)
        ministry.add_admin(admin.key_guid)

        delete "/v1/user_roles/#{SecureRandom.uuid}",
               { ministry: 'GUE' },
               'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status 404
      end
    end
  end

  describe 'GET /user_roles' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/user_roles'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with HTTP 401 for non-superadmin' do
        get '/v1/user_roles',
            { ministry: 'GUE' },
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end

      it 'returns single admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE', gr_id: SecureRandom.uuid)
        admin_key_guid = SecureRandom.uuid
        admin_gr_id = SecureRandom.uuid
        admin = create(:person, first_name: 'John', last_name: 'Doe', key_guid: admin_key_guid, gr_id: admin_gr_id)
        ministry.add_admin(admin.key_guid)

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(admin_roles).to eq 1

        get '/v1/user_roles',
            { ministry: 'GUE' },
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 1
        expect(json.first['key_guid']).to eq admin_key_guid
        expect(json.first['first_name']).to eq 'John'
        expect(json.first['last_name']).to eq 'Doe'
      end

      it 'returns multiple admins' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE', gr_id: SecureRandom.uuid)
        admin_key_guid = SecureRandom.uuid
        admin_gr_id = SecureRandom.uuid
        admin = create(:person, first_name: 'John', last_name: 'Doe', key_guid: admin_key_guid, gr_id: admin_gr_id)
        ministry.add_admin(admin.key_guid)
        admin2_key_guid = SecureRandom.uuid
        admin2_gr_id = SecureRandom.uuid
        admin2 = create(:person, first_name: 'Jane', last_name: 'Doegh', key_guid: admin2_key_guid, gr_id: admin2_gr_id)
        ministry.add_admin(admin2.key_guid)

        admin_roles = UserRole.where(ministry: ministry.gr_id).count
        expect(admin_roles).to eq 2

        get '/v1/user_roles',
            { ministry: 'GUE' },
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 2
        expect(json.first['key_guid']).to eq admin_key_guid
        expect(json.first['first_name']).to eq 'John'
        expect(json.first['last_name']).to eq 'Doe'
        expect(json.second['key_guid']).to eq admin2_key_guid
        expect(json.second['first_name']).to eq 'Jane'
        expect(json.second['last_name']).to eq 'Doegh'
      end

      it 'returns 400 for invalid ministry' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        get '/v1/user_roles',
            { ministry: 'DNE' },
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end
    end
  end
end
