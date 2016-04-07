# frozen_string_literal: true
module V1
  class ProfileSerializer < ActiveModel::Serializer
    DATE_FORMAT = '%Y-%m-%d'
    attributes :approved,
               :birth_date,
               :country_of_residence,
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
               :ministry_id,
               :ministry_of_employment,
               :organizational_status,
               :person_id,
               :preferred_name,
               :email

    has_many :assignments, serializer: MinistryAssignmentSerializer

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

    def date_joined_staff
      object.employment.try(:date_joined_staff).try(:strftime, DATE_FORMAT)
    end

    def date_left_staff
      object.employment.try(:date_left_staff).try(:strftime, DATE_FORMAT)
    end

    def organizational_status
      # return 'Other' if object.employment.try(:organizational_status) == 'Other_Status'
      object.employment.try(:organizational_status)
    end

    def funding_source
      # return 'Other' if object.employment.try(:funding_source) == 'Other_Source'
      object.employment.try(:funding_source)
    end

    def email
      object.email_address.try(:email)
    end
  end
end
