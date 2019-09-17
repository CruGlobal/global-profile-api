# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::CountrySerializer do
  describe "a ministry" do
    let(:country) { create(:country, iso_code: "ABC", name: "Alphabetistan") }
    let(:serializer) { V1::CountrySerializer.new(country) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
    let(:json) { serialization.as_json }

    it "has attributes" do
      expect(json.keys).to contain_exactly(:iso3, :name)
      expect(json[:iso3]).to_not be_nil
      expect(json[:name]).to_not be_nil
    end

    it "has correct values" do
      expect(json[:iso3]).to be_a(String).and(eq country.iso_code)
      expect(json[:name]).to be_a(String).and(eq country.name)
    end
  end
end
