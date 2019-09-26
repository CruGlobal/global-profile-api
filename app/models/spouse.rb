# frozen_string_literal: true

class Spouse < Person
  PERMITTED_ATTRIBUTES = [:spouse_id, :key_username, :first_name, :last_name, :marriage_date, :email].freeze

  attr_accessor :key_username

  class << self
    # Find or initialize person_id from GR with first_name, last_name, email and marriage_date
    def gr_id_for_spouse_attributes(attributes) # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
      # We need to create here so we have an id for client_integration_id
      person = find_or_create_by(attributes)
      return person.gr_id if person.gr_id.present?

      # Attempt to find person in GR first
      entity = gr_client.entity.get(:entity_type => "person",
                                    :fields => "id,first_name,last_name",
                                    "filters[first_name]" => attributes[:first_name],
                                    "filters[last_name]" => attributes[:last_name],
                                    "filters[email_address][email]" => attributes[:email],
                                    "filters[marriage_date]" => attributes[:marriage_date].strftime("%Y-%m-%d"))
                 &.dig("entities", 0, "person")
      person.update(gr_id: entity["id"]) && (return person.gr_id) if entity.present?

      # Create person if there is no match in GR
      entity = gr_client(attributes[:ministry])
        .entity.post(entity: {person: {
          first_name: person.first_name, last_name: person.last_name,
          marriage_date: person.marriage_date.strftime("%Y-%m-%d"),
          client_integration_id: person.id,
          email_address: {email: person.email,
                          client_integration_id: person.id,},
        }})&.dig("entity", "person")
      person.update(gr_id: entity["id"]) && (return person.gr_id) if entity.present?

      # Destroy person if we didn't find one and were unable to create them in GR.
      person.destroy
      nil
    end
  end
end
