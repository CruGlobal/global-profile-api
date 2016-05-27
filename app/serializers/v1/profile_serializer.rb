# frozen_string_literal: true
module V1
  class ProfileSerializer < ActiveModel::Serializer
    DATE_FORMAT = '%Y-%m-%d'
    attributes :approved,
               :birth_date,
               :date_joined_staff,
               :date_left_staff,
               :first_name,
               :funding_source,
               :gender,
               :is_secure,
               :key_guid,
               :language,
               :last_name,
               :marital_status,
               :marriage_date,
               :ministry_id,
               :ministry_of_employment,
               :organizational_status,
               :person_id,
               :preferred_name,
               :email,
               :phone_number,
               :skype_id,
               :staff_account

    has_many :assignments, serializer: MinistryAssignmentSerializer
    has_one :address, serializer: AddressSerializer
    has_one :spouse, serializer: SpouseSerializer
    has_many :children, serializer: ChildSerializer

    def person_id
      object.gr_id
    end

    def ministry_id
      object.ministry.try(:gr_id)
    end

    def ministry_of_employment
      object.employment&.ministry&.gr_id
    end

    def birth_date
      object.birth_date.try(:strftime, DATE_FORMAT)
    end

    def marriage_date
      object.marriage_date.try(:strftime, DATE_FORMAT)
    end

    def date_joined_staff
      object.employment.try(:date_joined_staff).try(:strftime, DATE_FORMAT)
    end

    def date_left_staff
      object.employment.try(:date_left_staff).try(:strftime, DATE_FORMAT)
    end

    def organizational_status
      object.employment.try(:organizational_status)
    end

    def funding_source
      object.employment.try(:funding_source)
    end

    def staff_account
      object.employment.try(:staff_account)
    end

    def children
      # Concat person.children with spouse.children while removing duplicates
      my_children = object.children.to_a
      # step_children = object.spouse&.children.select(:first_name, :last_name, :birth_date).to_a || []
      step_children = object.spouse&.children.to_a || []
      my_children.concat(step_children)
      my_children.uniq { |c| "#{c.first_name}:#{c.last_name}:#{c.birth_date.try(:strftime, DATE_FORMAT)}" }
    end
  end
end
