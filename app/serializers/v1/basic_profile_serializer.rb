# frozen_string_literal: true
module V1
  class BasicProfileSerializer < ActiveModel::Serializer
    attributes :person_id,
               :first_name,
               :last_name

    def person_id
      object.gr_id
    end
  end
end
