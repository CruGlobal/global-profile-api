# frozen_string_literal: true
FactoryGirl.define do
  factory :ministry do
    gr_id { SecureRandom.uuid }
    sequence(:name) { |n| "Test Ministry (#{n})" }
    min_code { ('A'..'Z').to_a.sample(3).join }
    active true
  end
end
