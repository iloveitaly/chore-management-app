source 'https://rubygems.org'
ruby '2.3.0'

gem 'dotenv-rails', '2.1.1', :groups => [:development, :test]
gem 'rails', '>= 5.0.0.rc2', '< 5.1'

# NOTE > 11.0.1 causes `last_comment` error
gem 'rake', '~> 10.5.0'

group :production, :staging do
  gem 'rails_12factor'
end

gem 'rollbar', '~> 2.11.2'
gem 'puma', '~> 3.4.0'

gem 'pg'
gem 'lograge'
gem 'rack-cors', :require => 'rack/cors'
gem "interactor", "~> 3.0"
gem 'acts_as_list', '~> 0.7.2'
gem 'rest-client'
gem 'ice_cube'

# login
# TODO https://github.com/lynndylanhurley/devise_token_auth/issues/606
# https://github.com/lynndylanhurley/devise_token_auth/issues/500
gem "omniauth-google-oauth2", '0.4.0'
gem 'active_model_serializers', '0.10.0.rc4'
# gem 'devise_token_auth', '0.1.37'
gem 'devise_token_auth', github: 'lynndylanhurley/devise_token_auth', ref: '10863b31270b31cec72a07e1a195aa21686ede2b'
gem 'devise', '4.0.3'

# assets
gem 'sass-rails', '~> 5.0'
gem 'uglifier', '>= 1.3.0'
gem "non-stupid-digest-assets"

group :development, :test do
  gem 'rspec', '~> 3.5.0.beta3'
  gem 'rspec-rails', '3.5.0.beta3'

  gem 'pry'
  gem 'pry-rescue', '~> 1.4.4'
  gem 'pry-stack_explorer'
  gem 'pry-nav'
  gem 'pry-remote'

  gem 'byebug'
end

group :development do
  # gem 'guard-rspec', '~> 4.6.5', require: false
  gem 'web-console', '~> 3.0'
  gem 'listen', '~> 3.0.5'

  gem 'better_errors'
  gem 'binding_of_caller'

  gem 'spring'
  gem 'spring-watcher-listen', '~> 2.0.0'

  gem 'quiet_assets'
end

group :test do
  gem 'simplecov', :require => false

  gem 'faker'
  gem 'factory_girl_rails', '~> 4.7.0'
  gem 'database_cleaner', '~> 1.5.2'

  gem 'capybara', '~> 2.7.1'
  gem 'capybara-angular'
  gem 'capybara-screenshot', '~> 1.0.12'
  gem 'capybara-webkit', '~> 1.11.1'
  gem 'selenium-webdriver', '~> 2.53.3'
  gem "chromedriver-helper", '~> 1.0.0'
  gem 'capybara_angular_helpers', github: 'iloveitaly/capybara_angular_helpers', ref: '4f17956bcbe4de437f0ca23e755e455623fa6a1e'
end
