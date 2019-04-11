# frozen_string_literal: true
require 'rails_helper'

RSpec.describe 'V1::Languages', type: :request do
  let(:json) { JSON.parse(response.body) }
  let(:languages) { File.read("#{Rails.root}/public/languages.json") }
  describe 'GET /v1/languages' do
    context 'without a session' do
      it 'responds with all languages' do
        get '/v1/languages'

        expect(response).to be_successful
        expect(response).to have_http_status :ok
        expect(json.size).to eq 535
        expect(json.sample.keys).to contain_exactly('iso_code', 'native_name', 'is_rtl', 'english_name')
      end
    end

    context 'with a session' do
      it 'responds with all languages' do
        get '/v1/languages', headers: { 'HTTP_AUTHORIZATION' => "Bearer #{authenticate_guid}" }

        expect(response).to be_successful
        expect(response).to have_http_status :ok
        expect(json.size).to eq 535
        expect(json.sample.keys).to contain_exactly('iso_code', 'native_name', 'is_rtl', 'english_name')
      end
    end
  end
end
