# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::MinistrySerializer do
  describe "a ministry" do
    let(:area) { create(:area, name: "Area Name", code: "AREA") }
    let(:ministry) { create(:ministry, area: area) }
    let(:serializer) { V1::MinistrySerializer.new(ministry) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
    let(:json) { serialization.as_json }

    it "has attributes" do
      expect(json.keys).to contain_exactly(:ministry_id, :name, :min_code, :area_code, :area_name)
      expect(json[:ministry_id]).to_not be_nil
      expect(json[:min_code]).to_not be_nil
    end

    it "has correct values" do
      expect(json[:ministry_id]).to be_a(String).and(eq ministry.gr_id)
      expect(json[:name]).to be_a(String).and(eq ministry.name)
      expect(json[:min_code]).to be_a(String).and(eq ministry.min_code)
      expect(json[:area_code]).to be_a(String).and(eq area.code)
      expect(json[:area_name]).to be_a(String).and(eq area.name)
    end
  end
end
