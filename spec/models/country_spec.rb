# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Country, type: :model do
  context '.refresh_from_gr' do
    it 'refreshes all iso_countries from global registry' do
      gr_id = SecureRandom.uuid
      allow(Country).to receive(:create_or_update_from_entity) { create(:country) }
      url = "#{ENV['GLOBAL_REGISTRY_URL']}/entities"\
        '?entity_type=iso_country&fields=name,iso3_code&levels=0'
      stub_request(:get, url).to_return(body: {
        entities: [
          iso_country: { id: gr_id }
        ],
        meta: { page: 1, next_page: false, from: 1, to: 1 }
      }.to_json)

      result = Country.refresh_from_gr
      expect(Country).to have_received(:create_or_update_from_entity).with('id' => gr_id)
      expect(result.size).to eq 1
    end
  end
end
