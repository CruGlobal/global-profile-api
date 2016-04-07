# frozen_string_literal: true
class Assignment < ActiveRecord::Base
  enum mcc: { 'Jesus Film' => 0, 'Prayer' => 1, 'Other' => 2, 'Student-Led Movements' => 3, 'Leader-Led Movements' => 4,
              'Global Church Movements' => 5, 'Capacity Accelerators' => 6, 'Operations' => 7, 'Area Team Leaders' => 8,
              'Fund Development' => 9, 'LDHR' => 10, 'Unknown' => 11, 'Digital Strategies' => 12 }
  enum position_role: { 'Team Member' => 1, 'Team Leader' => 2, 'Not Applicable' => 3 }
  enum scope: { 'Local' => 0, 'National Region' => 1, 'National' => 2, 'Area Region' => 3, 'Area' => 4, 'Global' => 5,
                'Executive' => 6 }

  PERMITTED_ATTRIBUTES = [:assignment_id, :ministry_id, :mcc, :position_role, :scope].freeze

  belongs_to :person
  belongs_to :ministry

  class << self
    def create_or_update_from_relationship(relationship)
      assignment = find_or_initialize_by(gr_id: relationship['relationship_entity_id'])
      assignment.update(mcc: relationship['mcc'], position_role: relationship['position_role'],
                        scope: relationship['scope'], ministry: Ministry.for_gr_id(relationship['ministry']))
      assignment
    end
  end
end
