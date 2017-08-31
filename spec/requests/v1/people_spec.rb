# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::People', type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:user_key_guid) { SecureRandom.uuid }
  let(:user_gr_id) { SecureRandom.uuid }
  let(:ministry_gr_id) { SecureRandom.uuid }
  let(:authenticate) { authenticate_guid(user_key_guid) }
  let(:ministry) { create(:ministry, gr_id: ministry_gr_id) }
  let!(:person) { create(:person, key_guid: user_key_guid, gr_id: user_gr_id, ministry: ministry) }

  before :each do
    allow(Person).to receive(:gr_id_for_key_guid).and_return user_gr_id
  end

  describe 'GET /people' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/people'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with one person (self) for non-admin' do
        get "/v1/people/?ministry_id=#{ministry_gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json['key_guid']).to eq user_key_guid
        expect(json['person_id']).to eq user_gr_id
        expect(json['ministry_id']).to eq ministry_gr_id
      end

      it 'responds with array of people for admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:admin])
        get "/v1/people/?ministry_id=#{ministry_gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 1
        expect(json.first['person_id']).to eq user_gr_id
      end

      it 'responds with all people in ministry for admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:admin])
        create(:person, ministry: ministry)
        create(:person, ministry: ministry)
        get "/v1/people/?ministry_id=#{ministry_gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 3
      end

      it 'responds with all people in same ministry for admin' do
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        create(:person, ministry: ministry)
        create(:person, ministry: ministry)
        get "/v1/people/?ministry_id=#{ministry_gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 3
      end

      it 'responds with all people in another ministry for superadmin' do
        create(:user_role, key_guid: user_key_guid, ministry: SecureRandom.uuid, role: UserRole.roles[:superadmin])
        new_ministry = create(:ministry, gr_id: SecureRandom.uuid)
        create(:person, ministry: new_ministry)
        create(:person, ministry: new_ministry)
        get "/v1/people/?ministry_id=#{new_ministry.gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.count).to eq 2
      end

      it 'does not respond with people in one ministry for admin of another' do
        create(:user_role, key_guid: user_key_guid, ministry: SecureRandom.uuid, role: UserRole.roles[:admin])
        new_ministry = create(:ministry, gr_id: SecureRandom.uuid)
        create(:person, ministry: new_ministry)
        create(:person, ministry: new_ministry)
        get "/v1/people/?ministry_id=#{new_ministry.gr_id}", nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :not_found
      end
    end
  end

  describe 'GET /people/:id' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get "/v1/people/#{user_gr_id}"

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with self for non-admin' do
        get "/v1/people/#{user_gr_id}?ministry_id=#{ministry_gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json['key_guid']).to eq user_key_guid
        expect(json['person_id']).to eq user_gr_id
        expect(json['ministry_id']).to eq ministry_gr_id
      end

      it 'does not show another person for non-admin' do
        new_person = create(:person, ministry: ministry, gr_id: SecureRandom.uuid)
        get "/v1/people/#{new_person.gr_id}?ministry_id=#{ministry_gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :not_found
      end

      it 'does show another person for admin' do
        new_person = create(:person, ministry: ministry, gr_id: SecureRandom.uuid)
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:admin])
        get "/v1/people/#{new_person.gr_id}?ministry_id=#{ministry_gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(json['person_id']).to eq new_person.gr_id
      end

      it 'does not show person in a ministry different than admin' do
        new_ministry = create(:ministry)
        new_person = create(:person, ministry: new_ministry, gr_id: SecureRandom.uuid)
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:admin])
        get "/v1/people/#{new_person.gr_id}?ministry_id=#{new_ministry.gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).not_to be_success
        expect(response).to have_http_status :not_found
      end

      it 'does show another person for superadmin' do
        new_person = create(:person, ministry: ministry, gr_id: SecureRandom.uuid)
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        get "/v1/people/#{new_person.gr_id}?ministry_id=#{ministry_gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        expect(response).to be_success
        expect(json['person_id']).to eq new_person.gr_id
      end

      it 'does show person in a ministry different than superadmin' do
        new_ministry = create(:ministry)
        new_person = create(:person, ministry: new_ministry, gr_id: SecureRandom.uuid)
        create(:user_role, key_guid: user_key_guid, ministry: ministry_gr_id, role: UserRole.roles[:superadmin])
        get "/v1/people/#{new_person.gr_id}?ministry_id=#{new_ministry.gr_id}",
            nil,
            'HTTP_AUTHORIZATION' => "Bearer #{authenticate}"

        Rails.logger.error("\e[91m #{json} \033[0m")
        expect(response).to be_success
        expect(json['person_id']).to eq new_person.gr_id
      end
    end
  end
end
