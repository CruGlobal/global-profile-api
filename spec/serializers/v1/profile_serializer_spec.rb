# frozen_string_literal: true
require 'rails_helper'

RSpec.describe V1::ProfileSerializer do
  describe 'a person' do
    let(:ministry) { create(:ministry) }
    let(:assignment) { create(:assignment, ministry: ministry) }
    let(:employment) do
      create(:employment, ministry: ministry, organizational_status: 'Full-time',
                          funding_source: 'Hybrid', date_left_staff: Time.current.to_date)
    end
    let(:person) { create(:person, ministry: ministry, assignments: [assignment], employment: employment) }
    let(:serializer) { V1::ProfileSerializer.new(person) }
    let(:serialization) { ActiveModelSerializers::Adapter.create(serializer) }
    let(:json) { serialization.as_json }

    it 'has attributes' do
      expect(json.keys).to contain_exactly(*%i(approved assignments birth_date date_joined_staff
                                               date_left_staff email first_name funding_source gender
                                               is_secure key_guid language last_name marital_status ministry_id
                                               ministry_of_employment organizational_status person_id preferred_name
                                               address children marriage_date phone_number skype_id spouse
                                               staff_account))
      expect(json[:assignments]).to be_an(Array).and(all(include(*%i(assignment_id mcc ministry_id
                                                                     position_role scope))))
      expect(json[:language]).to be_an(Array).and(all(be_a(String)))
      expect(json[:person_id]).to be_uuid
      expect(json[:key_guid]).to be_uuid
      expect(json[:ministry_id]).to be_uuid
      expect(json[:ministry_of_employment]).to be_uuid
    end

    it 'has correct values' do
      expect(json[:approved]).to eq person.approved
      expect(json[:birth_date]).to eq person.birth_date.strftime(V1::ProfileSerializer::DATE_FORMAT)
      expect(json[:date_joined_staff]).to eq employment.date_joined_staff.strftime(V1::ProfileSerializer::DATE_FORMAT)
      expect(json[:date_left_staff]).to eq employment.date_left_staff.strftime(V1::ProfileSerializer::DATE_FORMAT)
      expect(json[:first_name]).to eq person.first_name
      expect(json[:is_secure]).to eq person.is_secure
      expect(json[:funding_source]).to eq employment.funding_source
      expect(json[:gender]).to eq person.gender
      expect(json[:key_guid]).to eq person.key_guid
      expect(json[:last_name]).to eq person.last_name
      expect(json[:marital_status]).to eq person.marital_status
      expect(json[:ministry_id]).to eq person.ministry.gr_id
      expect(json[:ministry_of_employment]).to eq employment.ministry.gr_id
      expect(json[:organizational_status]).to eq employment.organizational_status
      expect(json[:person_id]).to eq person.gr_id
      expect(json[:preferred_name]).to eq person.preferred_name
      expect(json[:assignments][0][:assignment_id]).to be_uuid.and(eq assignment.gr_id)
      expect(json[:assignments][0][:mcc]).to eq assignment.mcc
      expect(json[:assignments][0][:ministry_id]).to be_uuid.and(eq assignment.ministry.gr_id)
      expect(json[:assignments][0][:position_role]).to eq assignment.position_role
      expect(json[:assignments][0][:scope]).to eq assignment.scope
    end

    context 'profile with \'Other\' status and source' do
      let(:employment) do
        create(:employment, ministry: ministry, organizational_status: 'Other_Status', funding_source: 'Other_Source')
      end
      it 'serializers enum special cases correctly' do
        expect(json[:organizational_status]).to eq 'Other'
        expect(json[:funding_source]).to eq 'Other'
      end
    end
  end
end
