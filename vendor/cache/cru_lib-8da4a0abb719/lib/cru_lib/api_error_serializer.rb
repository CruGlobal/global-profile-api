module CruLib
  class ApiErrorSerializer < ActiveModel::Serializer
    attributes :message

    def _type
      'api_error'
    end

    def id
      _type
    end
  end
end