# frozen_string_literal: true
class EmailAddress < ActiveRecord::Base
  belongs_to :person

  def as_entity
    entity = { email: email, location: location, primary: primary?, client_integration_id: id }
    entity = entity.merge(id: gr_id) if gr_id.present?
    entity
  end

  class << self
    def create_or_update_from_entity(entity)
      email_address = find_or_initialize_by(gr_id: entity['id'])
      email_address.update(email: entity['email'], primary: entity['primary'] || false, location: entity['location'])
      email_address
    end
  end
end
