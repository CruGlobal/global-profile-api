# frozen_string_literal: true
module V1
  class UserUpdatedPerson < ::Person
    attr_accessor :key_username

    accepts_nested_attributes_for :assignments
    accepts_nested_attributes_for :employment
    accepts_nested_attributes_for :email_addresses

    before_save :lookup_guid_from_username, if: 'gr_id.blank?'

    def assignments_attributes=(collection)
      collection = collection.map do |attributes|
        attributes[:gr_id] = attributes.delete(:assignment_id)
        assignment = Assignment.find_by(gr_id: attributes[:gr_id]) if Uuid.uuid?(attributes[:gr_id])
        attributes[:id] = assignment.id if assignment.present?

        ministry_gr_id = attributes.delete(:ministry_id)
        attributes[:ministry] = Ministry.for_gr_id(ministry_gr_id) if ministry_gr_id.present?
        attributes
      end
      ids = collection.map { |a| a[:id] }.compact
      assignments.where.not(id: ids).destroy_all
      super collection
    end

    def employment_attributes=(attribute_collection)
      # Map `ministry_of_employment` to ministry_id
      ministry_gr_id = attribute_collection.delete(:ministry_of_employment)
      attribute_collection[:ministry] = Ministry.for_gr_id(ministry_gr_id) if ministry_gr_id.present?

      # Always update existing employment
      attribute_collection[:id] = employment.try(:id)
      super
    end

    def email_addresses_attributes=(collection)
      # Person stores multiple email_addresses, v1 only deals with the first
      attributes = Array.wrap(collection).first
      email = email_address
      if attributes.key?(:email)
        email = email_addresses.build if email.blank?
        email.update(email: attributes[:email], primary: true)
      elsif email.present?
        email.destroy
      end
    end

    def lookup_guid_from_username
      return unless key_username.present?
      attributes = TheKey::UserAttributes.new(email: key_username).cas_attributes
      self.key_guid = attributes['theKeyGuid'] if attributes.key?('theKeyGuid')
    rescue RestClient::ResourceNotFound
      nil
    end
  end
end
