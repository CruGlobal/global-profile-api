# frozen_string_literal: true

require "rails_helper"

RSpec.describe Area, type: :model do
  context ".for_code" do
    it "returns nil for nil" do
      expect(Area.for_code(nil)).to be_nil
    end

    it "finds an existing area by code" do
      area = create(:area, code: "AAOP")
      expect(Area.for_code("AAOP")).to eq area
    end

    it "queries global registry and creates a new area if one does not exist" do
      gr_id = SecureRandom.uuid
      url = "#{ENV["GLOBAL_REGISTRY_URL"]}/entities?entity_type=area&"\
        "fields=area_name,area_code&filters[area_code]=EUWE"
      stub_request(:get, url).to_return(body: {
        entities: [{
          area: {
            id: gr_id, area_code: "EUWE",
            area_name: "Western Europe",
          },
        }],
      }.to_json)

      area = Area.for_code("EUWE")

      expect(area).to_not be_new_record
      expect(area.gr_id).to eq gr_id
      expect(area.code).to eq "EUWE"
      expect(area.name).to eq "Western Europe"
    end

    context ".for_gr_id" do
      it "returns nil for nil" do
        expect(Area.for_gr_id(nil)).to be_nil
      end

      it "finds an existing area by gr_id" do
        gr_id = SecureRandom.uuid
        area = create(:area, gr_id: gr_id)

        expect(Area.for_gr_id(gr_id)).to eq area
      end

      it "queries global registry and creates a new area if one does not exist" do
        gr_id = SecureRandom.uuid
        url = "#{ENV["GLOBAL_REGISTRY_URL"]}/entities/#{gr_id}"
        stub_request(:get, url).to_return(body: {
          entity: {
            area: {
              id: gr_id, area_code: "EUWE",
              area_name: "Western Europe",
            },
          },
        }.to_json)

        area = Area.for_gr_id(gr_id)

        expect(area).to_not be_new_record
        expect(area.gr_id).to eq gr_id
        expect(area.code).to eq "EUWE"
        expect(area.name).to eq "Western Europe"
      end
    end
  end
end
