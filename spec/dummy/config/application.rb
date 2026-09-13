require_relative "boot"

require "dotenv/load"
require "active_record/railtie"
require "active_model/railtie"
require "active_job/railtie"
require "active_storage/engine"
# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f

    # For compatibility with applications that use this config
    # config.action_controller.include_all_helpers = false
    # config.load_defaults 8.1
    #
    # config.eager_load = false

    config.paths["db/migrate"] << Rails.root.join("../../db/migrate")
  end
end
