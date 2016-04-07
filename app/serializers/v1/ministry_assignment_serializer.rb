# frozen_string_literal: true
module V1
  class MinistryAssignmentSerializer < ActiveModel::Serializer
    attribute :gr_id, key: :assignment_id
    attributes :mcc, :ministry_id, :position_role, :scope

    def ministry_id
      object.ministry.try(:gr_id)
    end

    delegate :scope, to: :object
  end
end
