# frozen_string_literal: true
module V1
  class SpouseSerializer < ActiveModel::Serializer
    attributes :spouse_id, :first_name, :last_name

    def spouse_id
      object.gr_id
    end
  end
end
