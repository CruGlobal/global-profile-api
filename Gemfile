source 'https://rubygems.org'
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby '2.3.8'

gem 'rails', '~> 5.2.3'
gem 'puma', '~> 3.11'

gem 'bootsnap', '>= 1.1.0', require: false

gem 'active_model_serializers', git: 'https://github.com/rails-api/active_model_serializers.git'
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
  gem 'byebug', platforms: [:mri, :mingw, :x64_mingw]

  gem 'dotenv-rails'
  gem 'guard-rubocop'
  gem 'guard-rspec'
  gem 'rspec-rails'
  gem 'spring-commands-rspec'
  gem 'pry-rails'
  gem 'pry-byebug'
  gem 'http_logger'
  gem 'awesome_print'
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> anywhere in the code.
  gem 'web-console', '>= 3.3.0'
  gem 'listen', '>= 3.0.5', '< 3.2'
  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'
end

group :test do
  gem 'capybara', '>= 2.15'
  gem 'selenium-webdriver'
  gem 'chromedriver-helper'
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
