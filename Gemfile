source "https://rubygems.org"

# Specify your gem's dependencies in key_harbour_core.gemspec.
gemspec

gem "puma"

gem "pg"
gem "bcrypt", "~> 3.1.21"
gem "meilisearch-rails"
gem "csv"
gem 'pagy'
gem "unique_names_generator"
gem "colorize"
# Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
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
