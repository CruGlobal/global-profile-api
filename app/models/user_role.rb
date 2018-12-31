# frozen_string_literal: true
class UserRole < ApplicationRecord
  enum role: { admin: 0 }

  belongs_to :gr_ministry, foreign_key: :ministry, class_name: 'Ministry', primary_key: :gr_id, inverse_of: :user_roles
  belongs_to :person, foreign_key: :key_guid, class_name: 'Person', primary_key: :key_guid, inverse_of: :user_roles
end
