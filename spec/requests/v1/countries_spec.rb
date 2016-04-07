# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::Countries', type: :request do
  let(:json) { JSON.parse(response.body) }
  describe 'GET /v1/countries' do
    context 'without a session' do
      it 'responds with HTTP 401' do
        get '/v1/countries'

        expect(response).not_to be_success
        expect(response).to have_http_status :unauthorized
      end
    end

    context 'with a session' do
      it 'responds with all countries' do
        create(:country, iso_code: 'ABC', name: 'Alphabetistan')
        create(:country, iso_code: 'XYZ', name: 'Xylophonia')
        create(:country, iso_code: 'PDQ', name: 'Please and Thankyou')

        get '/v1/countries', nil, 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}"

        expect(response).to be_success
        expect(response).to have_http_status :ok
        expect(json.size).to eq 3
      end
    end
  end
end
