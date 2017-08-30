# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::Ministries', type: :request do
  let(:json) { JSON.parse(response.body) }
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

        get '/v1/ministries', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.size).to eq 2
      end

      context 'show_inactive=true' do
        it 'responds with all ministries including inactive ones' do
          create(:ministry)
          create(:ministry, gp_key: SecureRandom.uuid)
          create(:ministry, active: false)

          get '/v1/ministries?show_inactive=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

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

          get '/v1/ministries?global_profile_only=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

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

          get '/v1/ministries?refresh=true', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

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
      it 'activates a ministry' do
        ministry = instance_double('Ministry', min_code: 'GUE')
        allow(ministry).to receive(:activate_site) { nil }
        allow(ministry).to receive(:name) { 'Test' }
        allow(Ministry).to receive(:find_by) { ministry }

        put '/v1/ministries/GUE', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(ministry).to have_received(:activate_site)
      end

      it 'returns 404 for invalid ministry' do
        put '/v1/ministries/DNE', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).not_to be_success
        expect(response).to have_http_status 404
      end
    end
  end
end
