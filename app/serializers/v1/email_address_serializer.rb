# frozen_string_literal: true
module V1
  class EmailAddressSerializer < ActiveModel::Serializer
    attribute :email, key: :email_address
    attributes :primary, :location
  end
end
