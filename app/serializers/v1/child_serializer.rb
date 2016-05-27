# frozen_string_literal: true
module V1
  class ChildSerializer < ActiveModel::Serializer
    attributes :id, :first_name, :last_name, :birth_date

    def birth_date
      object.birth_date.try(:strftime, ProfileSerializer::DATE_FORMAT)
    end
  end
end
