# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::Ministries', type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user_key_guid) { SecureRandom.uuid }
  let(:user_gr_id) { SecureRandom.uuid }
  let(:ministry_gr_id) { SecureRandom.uuid }
  let(:authenticate) { authenticate_guid(user_key_guid) }
  let(:ministry) { create(:ministry, gr_id: ministry_gr_id) }
  let(:user) { create(:person, key_guid: user_key_guid, gr_id: user_gr_id, ministry: ministry) }

  before :each do
    allow(Person).to receive(:gr_id_for_key_guid).and_return user_key_guid
  end

  describe 'GET /ministries' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/ministries'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with all active ministries' do
        create(:ministry)
        create(:ministry, gp_key: SecureRandom.uuid)
        create(:ministry, active: false)

        get '/v1/ministries', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.size).to eq 2
      end

      context 'show_inactive=true' do
        it 'responds with all ministries including inactive ones' do
          create(:ministry)
          create(:ministry, gp_key: SecureRandom.uuid)
          create(:ministry, active: false)

          get '/v1/ministries?show_inactive=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

          expect(response).to be_success
          expect(response).to have_http_status :ok
          expect(json.size).to eq 3
        end
      end

      context 'global_profile_only=true' do
        it 'responds with only global profile ministries' do
          create(:ministry)
          create(:ministry, gp_key: SecureRandom.uuid)
          create(:ministry, active: false)

          get '/v1/ministries?global_profile_only=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

          expect(response).to be_success
          expect(response).to have_http_status :ok
          expect(json.size).to eq 1
        end
      end

      context 'refresh=true' do
        it 'reload ministries from global registry' do
          create(:ministry)
          create(:ministry, gp_key: SecureRandom.uuid)
          create(:ministry, active: false)
          allow(Ministry).to receive(:refresh_from_gr) { Ministry.all }

          get '/v1/ministries?refresh=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

          expect(Ministry).to have_received(:refresh_from_gr)
          expect(response).to be_success
          expect(response).to have_http_status :ok
          expect(json.size).to eq 2
        end
      end
    end
  end

  describe 'PUT /ministries/:min_code' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/ministries'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with HTTP 401 for non-superadmin' do
        ministry = instance_double('Ministry', min_code: 'GUE')
        allow(ministry).to receive(:activate_site) { true }
        allow(Ministry).to receive(:find_by) { ministry }

        put '/v1/ministries/GUE', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to_not be_success
        expect(response).to have_http_status :unauthorized
      end

      it 'activates a ministry for a superadmin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        ministry = create(:ministry, min_code: 'GUE')
        allow(ministry).to receive(:activate_site) { true }
        allow(Ministry).to receive(:find_by) { ministry }

        put '/v1/ministries/GUE', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(ministry).to have_received(:activate_site)
      end

      it 'returns 400 for invalid ministry for a superadmin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])

        put '/v1/ministries/DNE', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :bad_request
      end
    end
  end
end
