# frozen_string_literal: true
class UserRole < ActiveRecord::Base
  enum role: { admin: 0, superadmin: 1 }

  belongs_to :gr_ministry, foreign_key: :ministry, class_name: 'Ministry', primary_key: :gr_id, inverse_of: :user_roles
  belongs_to :person, foreign_key: :key_guid, class_name: 'Person', primary_key: :key_guid, inverse_of: :user_roles

  def self.superadmin?(user_key_guid)
    exists?(key_guid: user_key_guid, role: roles[:superadmin])
  end
end
