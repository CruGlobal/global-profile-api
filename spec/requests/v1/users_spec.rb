# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::User', type: :request do
  let(:json) { JSON.parse(response.body) }

  before :each do
    @key_guid = SecureRandom.uuid
    @gr_id = SecureRandom.uuid
    @authenticate = authenticate_guid(@key_guid)
    @person = create(:person, key_guid: @key_guid, gr_id: @gr_id, ministry: nil)
    allow(Person).to receive(:gr_id_for_key_guid).and_return @gr_id
  end

  describe 'GET /user' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/user/'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'returns current user' do

        get '/v1/user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{@authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json['key_guid']).to eq @key_guid
        expect(json['person_id']).to eq @gr_id
      end

      it 'returns current user with admin roles' do
        min_guids = [SecureRandom.uuid, SecureRandom.uuid]
        min_guids.each { |ministry| create(:user_role, key_guid: @key_guid, ministry: ministry, role: UserRole.roles[:admin]) }

        get '/v1/user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{@authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json['key_guid']).to eq @key_guid
        expect(json['person_id']).to eq @gr_id
        expect(json['admin']).to match_array(min_guids)
        expect(json['superadmin']).to eq false
      end

      it 'returns current user with superadmin bit' do
        create(:user_role, key_guid: @key_guid, ministry: SecureRandom.uuid, role: UserRole.roles[:superadmin])

        get '/v1/user', nil, 'HTTP_AUTHORIZATION' => "Bearer #{@authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json['key_guid']).to eq @key_guid
        expect(json['person_id']).to eq @gr_id
        expect(json['superadmin']).to eq true
      end
    end
  end

end
