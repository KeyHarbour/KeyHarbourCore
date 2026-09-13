source "https://rubygems.org"

gemspec
gem "rails", "~> 8.1.3"
gem "puma"

gem "pg"
gem "bcrypt", "~> 3.1.21"
gem "meilisearch-rails"
gem "csv"
gem 'pagy'
gem "unique_names_generator"
gem "colorize"
gem "rubocop-rails-omakase", require: false

group :development, :test do
  gem 'rspec-rails'
  gem 'dotenv-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers'
  gem "faker"
end

group :test do
  gem 'database_cleaner'
  gem 'simplecov', require: false
end
