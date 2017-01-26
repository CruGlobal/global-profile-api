module CruLib
  class ApiError < ActiveModelSerializers::Model
    attr_accessor :message, :options
  end
end