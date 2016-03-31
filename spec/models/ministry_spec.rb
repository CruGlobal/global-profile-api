# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Ministry, type: :model do
  context '.for_code' do
    it 'returns nil for nil' do
      expect(Ministry.for_min_code(nil)).to be_nil
    end

    it 'finds an existing ministry by min_code' do
      ministry = create(:ministry, min_code: 'GUE')
      expect(Ministry.for_min_code('GUE')).to eq ministry
    end

    it 'queries global registry and creates a new ministry if one does not exist' do
      gr_id = SecureRandom.uuid
      area = create(:area, gr_id: SecureRandom.uuid, name: 'Area Name', code: 'AREA')
      allow(Area).to receive(:for_gr_id) { area }
      url = "#{ENV['GLOBAL_REGISTRY_URL']}/entities?entity_type=ministry&levels=0&ruleset=global_ministries&"\
        'fields=name,min_code,area:relationship,is_active&filters[min_code]=GUE'
      stub_request(:get, url).to_return(body: {
        entities: [{
          ministry: {
            id: gr_id, min_code: 'GUE', is_active: true, name: 'Guatemala',
            'area:relationship' => { area: area.gr_id }
          }
        }]
      }.to_json)

      ministry = Ministry.for_min_code('GUE')

      expect(Area).to have_received(:for_gr_id).with(area.gr_id)
      expect(ministry).to_not be_new_record
      expect(ministry.gr_id).to eq gr_id
      expect(ministry.min_code).to eq 'GUE'
      expect(ministry.active).to eq true
      expect(ministry.name).to eq 'Guatemala'
      expect(ministry.area).to eq area
    end
  end

  context '.for_gr_id' do
    it 'returns nil for nil' do
      expect(Ministry.for_gr_id(nil)).to be_nil
    end

    it 'finds an existing ministry by gr_id' do
      gr_id = SecureRandom.uuid
      ministry = create(:ministry, gr_id: gr_id)

      expect(Ministry.for_gr_id(gr_id)).to eq ministry
    end

    it 'queries global registry and creates a new ministry if one does not exist' do
      gr_id = SecureRandom.uuid
      area = create(:area, gr_id: SecureRandom.uuid, name: 'Area Name', code: 'AREA')
      allow(Area).to receive(:for_gr_id) { area }
      url = "#{ENV['GLOBAL_REGISTRY_URL']}/entities/#{gr_id}?entity_type=ministry&"\
          'levels=0&fields=name,min_code,area:relationship,is_active&ruleset=global_ministries'
      stub_request(:get, url).to_return(body: {
        entity: {
          ministry: {
            id: gr_id, min_code: 'GUE', is_active: true, name: 'Guatemala',
            'area:relationship' => { area: area.gr_id }
          }
        }
      }.to_json)

      ministry = Ministry.for_gr_id(gr_id)

      expect(Area).to have_received(:for_gr_id).with(area.gr_id)
      expect(ministry).to_not be_new_record
      expect(ministry.gr_id).to eq gr_id
      expect(ministry.min_code).to eq 'GUE'
      expect(ministry.active).to eq true
      expect(ministry.name).to eq 'Guatemala'
      expect(ministry.area).to eq area
    end
  end

  context '.refresh_from_gr' do
    it 'refreshes all ministries from global registry' do
      gr_id = SecureRandom.uuid
      allow(Ministry).to receive(:create_or_update_from_entity) { create(:ministry) }
      url = "#{ENV['GLOBAL_REGISTRY_URL']}/entities"\
        '?entity_type=ministry&fields=name,min_code,area:relationship,is_active&levels=0&ruleset=global_ministries'
      stub_request(:get, url).to_return(body: {
        entities: [
          { ministry: { id: gr_id } }, { ministry: { id: SecureRandom.uuid } }, { ministry: { id: SecureRandom.uuid } }
        ],
        meta: { page: 1, next_page: false, from: 1, to: 1 }
      }.to_json)

      result = Ministry.refresh_from_gr
      expect(Ministry).to have_received(:create_or_update_from_entity).with('id' => gr_id)
      expect(result.size).to eq 3
    end
  end
end
