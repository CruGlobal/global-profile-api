# frozen_string_literal: true
FactoryGirl.define do
  sequence(:random_name) { ('a'..'z').to_a.shuffle[0, 3 + rand(10)].join.capitalize }
  factory :person do
    gr_id { SecureRandom.uuid }
    first_name { generate(:random_name) }
    last_name { generate(:random_name) }
    gender { Person.genders.keys.sample }
    birth_date { rand(Date.new(1950)..Date.new(1980)) }
    marital_status { Person.marital_statuses.keys.sample }
    language { %w(en-US en-GB fr-FR nl-NL hi-IN pt-BR es-CR).sample(2) }
    key_guid { SecureRandom.uuid }
    approved { [false, true].sample }
    is_secure { [false, true].sample }
  end
end
