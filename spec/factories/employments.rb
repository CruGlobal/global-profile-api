# frozen_string_literal: true
FactoryGirl.define do
  factory :employment do
    gr_id { SecureRandom.uuid }
    date_joined_staff { rand(Date.new(1980)..Time.current.to_date) }
    organizational_status { Person.organizational_statuses.keys.sample }
    funding_source { Person.funding_sources.keys.sample }
  end
end
