# frozen_string_literal: true
module V1
  class MinistrySerializer < ActiveModel::Serializer
    attribute :gr_id, key: :ministry_id
    attributes :name, :min_code, :area_name, :area_code

    def area_name
      object.area.try(:name)
    end

    def area_code
      object.area.try(:code)
    end
  end
end
