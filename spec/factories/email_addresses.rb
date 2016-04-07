# frozen_string_literal: true
FactoryGirl.define do
  factory :email_address do
    gr_id { SecureRandom.uuid }
    email { "#{generate(:random_name)}.#{generate(:random_name)}@example.com" }
    primary true
  end
end
