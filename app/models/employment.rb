# frozen_string_literal: true
class Employment < ActiveRecord::Base
  # Both organizational status status and funding source have value 'Other', this is not allowed by active record
  # We will suffix each by type, but the serializer, controller and model need to know to change values to match

  # Other => Other_Status
  enum organizational_status: { 'Full-time' => 0, 'Short-term' => 1, 'Part-time' => 2, 'Other_Status' => 3,
                                'Volunteer' => 4 }
  # Other => Other_Source
  enum funding_source: { 'Supported Staff' => 0, 'Centrally Funded Staff' => 1, 'Self-funded' => 2, 'Other_Source' => 3,
                         'Hybrid' => 4 }

  PERMITTED_ATTRIBUTES = [:organizational_status, :funding_source, :date_joined_staff, :date_left_staff,
                          :ministry_of_employment].freeze

  belongs_to :person
  belongs_to :ministry

  def organizational_status
    value = super
    value = 'Other' if value == 'Other_Status'
    value
  end

  def organizational_status=(value)
    value = 'Other_Status' if value.to_s == 'Other'
    super
  end

  def funding_source
    value = super
    value = 'Other' if value == 'Other_Source'
    value
  end

  def funding_source=(value)
    value = 'Other_Source' if value.to_s == 'Other'
    super
  end

  class << self
    def create_or_update_from_relationship(relationship)
      employment = find_or_initialize_by(gr_id: relationship['relationship_entity_id'])
      # Transform enum values
      relationship['organizational_status'] = 'Other_Status' if relationship['organizational_status'] == 'Other'
      relationship['funding_source'] = 'Other_Source' if relationship['funding_source'] == 'Other'
      employment.update(date_joined_staff: relationship['date_joined_staff'],
                        date_left_staff: relationship['date_left_staff'],
                        organizational_status: relationship['organizational_status'],
                        funding_source: relationship['funding_source'],
                        ministry: Ministry.for_gr_id(relationship['ministry']))
      employment
    end
  end
end
