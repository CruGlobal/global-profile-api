# frozen_string_literal: true
class UserRole < ActiveRecord::Base
  enum role: { admin: 0 }
end
