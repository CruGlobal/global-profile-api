# frozen_string_literal: true
FactoryGirl.define do
  factory :assignment do
    gr_id { SecureRandom.uuid }
    mcc { Assignment.mccs.keys.sample }
    position_role { Assignment.position_roles.keys.sample }
    scope { Assignment.scopes.keys.sample }
  end
end
