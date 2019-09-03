# frozen_string_literal: true

module V1
  class UserUpdatedPerson < ::Person
    attr_accessor :key_username, :spouse_attributes

    accepts_nested_attributes_for :assignments
    accepts_nested_attributes_for :employment
    accepts_nested_attributes_for :address
    accepts_nested_attributes_for :children

    before_save :set_guid_from_username, if: -> { gr_id.blank? }
    after_save :push_to_gr, if: -> { ministry.present? }

    def assignments_attributes=(collection)
      collection = collection.map { |attributes|
        attributes[:gr_id] = attributes.delete(:assignment_id)
        assignment = Assignment.find_by(gr_id: attributes[:gr_id]) if Uuid.uuid?(attributes[:gr_id])
        attributes[:id] = assignment.id if assignment.present?

        ministry_gr_id = attributes.delete(:ministry_id)
        attributes[:ministry] = Ministry.for_gr_id(ministry_gr_id) if ministry_gr_id.present?
        attributes
      }
      ids = collection.map { |a| a[:id] }.compact
      assignments.where.not(id: ids).destroy_all
      super collection
    end

    def employment_attributes=(attribute_collection)
      # Map `ministry_of_employment` to ministry_id
      ministry_gr_id = attribute_collection.delete(:ministry_of_employment)
      attribute_collection[:ministry] = Ministry.for_gr_id(ministry_gr_id) || ministry

      # Always update existing employment
      attribute_collection[:id] = employment.try(:id)
      super
    end

    def set_guid_from_username
      self.key_guid = lookup_guid_from_username(key_username) if key_username.present?
    end

    def lookup_guid_from_username(username)
      return unless username.present?
      attributes = TheKey::UserAttributes.new(email: username).cas_attributes
      attributes["theKeyGuid"] if attributes.key?("theKeyGuid")
    rescue RestClient::ResourceNotFound
      nil
    end

    def address_attributes=(attribute_collection)
      return unless attribute_collection
      # Always update existing address
      attribute_collection[:id] = address.try(:id)
      super
    end

    def children_attributes=(collection)
      # Remove all children if collection is missing or empty
      children.destroy_all && return unless collection.present?
      ids = collection.map { |a| a[:id] }.compact
      # Destroy children missing from collection
      children.where.not(id: ids).destroy_all
      # Remove children belonging to spouse
      spouse_ids = spouse&.children&.ids
      collection.reject! { |c| spouse_ids.include? c["id"] } if spouse_ids.present?
      # Call super to add/update remaining children
      super collection
    end

    def set_spouse_from_attributes # rubocop:disable Metrics/AbcSize, Metrics/MethodLength, Metrics/PerceivedComplexity
      # Remove spouse if spouse attributes are missing
      if spouse_attributes.blank?
        spouse.update_columns(spouse_id: nil, spouse_rel_id: nil) if spouse.present?
        self.spouse = nil
        return
      end
      if spouse_attributes.key?(:key_username)
        # Lookup spouse_id by key_username
        guid = lookup_guid_from_username(spouse_attributes[:key_username])
        unless guid.present?
          raise ActiveRecord::RecordInvalid,
                "TheKey username #{spouse_attributes[:key_username]} is invalid or does not exist."
        end
        spouse_attributes[:spouse_id] = Person.gr_id_for_key_guid(guid, ministry) if guid.present?
      elsif [:first_name, :last_name, :email].all? { |k| spouse_attributes.key?(k) }
        # Lookup or create spouse by personal details
        spouse_attributes[:spouse_id] = Spouse.gr_id_for_spouse_attributes(first_name: spouse_attributes[:first_name],
                                                                           last_name: spouse_attributes[:last_name],
                                                                           email: spouse_attributes[:email],
                                                                           marriage_date: marriage_date,
                                                                           ministry: ministry)
      end
      updated_spouse = Person.for_gr_id(spouse_attributes[:spouse_id], ministry)
      self.spouse = updated_spouse
      if updated_spouse.present?
        updated_spouse.spouse = self
        updated_spouse.marriage_date = marriage_date
        updated_spouse.marital_status = marital_status
      end
    end
  end
end
