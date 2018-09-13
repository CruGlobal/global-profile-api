source 'https://rubygems.org'

gem 'rails', '~> 4.2.10'
gem 'rails-api'
gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
gem 'puma'
gem 'newrelic_rpm'
gem 'rails-api-newrelic'
gem 'versionist'
gem 'rack-cors', require: 'rack/cors'
gem 'rollbar'
gem 'syslog-logger'
gem 'oj'
gem 'oj_mimic_json'
gem 'cru-auth-lib', '~> 0.1.0'
gem 'pg'
gem 'redis-namespace'
gem 'sinatra', :require => nil
gem 'auto_strip_attributes', '~> 2.0'
gem 'arel'
gem 'consul'
gem 'assignable_values'
gem 'global_registry'
gem 'ddtrace'
gem 'dogstatsd-ruby'

group :development, :test do
  gem 'dotenv-rails'
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'spring'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'http_logger'
  gem 'awesome_print'
end

group :test do
  gem 'webmock'
  gem 'simplecov', require: false
  gem 'factory_girl_rails'
  gem 'shoulda', require: false
  gem 'rspec-json_expectations', require: 'rspec/json_expectations'
  gem 'rubocop'
  gem 'mock_redis'
  gem 'fakeredis', :require => 'fakeredis/rspec'
  gem 'coveralls', require: false
end

# add this at the end so it plays nice with pry
gem 'marco-polo'
