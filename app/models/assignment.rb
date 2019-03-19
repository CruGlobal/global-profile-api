# frozen_string_literal: true
class Assignment < ApplicationRecord
  enum mcc: { 'Jesus Film' => 0, 'Prayer' => 1, 'Other' => 2, 'Student-Led Movements' => 3, 'Leader-Led Movements' => 4,
              'Global Church Movements' => 5, 'Capacity Accelerators' => 6, 'Operations' => 7, 'Area Team Leaders' => 8,
              'Fund Development' => 9, 'LDHR' => 10, 'Unknown' => 11, 'Digital Strategies' => 12 }
  enum position_role: { 'Team Member' => 1, 'Team Leader' => 2, 'Not Applicable' => 3 }
  enum scope: { 'Local' => 0, 'National Region' => 1, 'National' => 2, 'Area Region' => 3, 'Area' => 4, 'Global' => 5,
                'Executive' => 6 }

  PERMITTED_ATTRIBUTES = [:assignment_id, :ministry_id, :mcc, :position_role, :scope].freeze

  belongs_to :person, optional: true
  belongs_to :ministry

  after_destroy :destroy_gr_relationship, if: 'gr_id.present?'

  def as_gr_relationship
    { ministry: ministry.try(:gr_id), mcc: mcc, position_role: position_role, scope: scope,
      client_integration_id: "global_profile:assignment:#{id}", ministry_of_service: true }
  end

  private

  def destroy_gr_relationship
    person.ministry.gr_ministry_client.entity.delete(gr_id)
  end

  class << self
    def create_or_update_from_relationship(relationship)
      assignment = find_or_initialize_by(gr_id: relationship['relationship_entity_id'])
      assignment.update(mcc: relationship['mcc'], position_role: relationship['position_role'],
                        scope: relationship['scope'], ministry: Ministry.for_gr_id(relationship['ministry']))
      assignment
    end
  end
end
