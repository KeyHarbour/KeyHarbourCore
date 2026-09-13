require "active_record/railtie"
require "active_model/railtie"
require "active_job/railtie"
require "active_storage/engine"

module KeyHarbourCore
  class Engine < ::Rails::Engine
    isolate_namespace KeyHarbourCore

    config.generators do |g|
      g.test_framework :rspec
      # Force la génération des factories dans le dossier spec/factories de l'engine
      g.factory_bot dir: 'spec/factories'
    end

    initializer "mon_engine.factories", after: "factory_bot.set_factory_paths" do
      if defined?(FactoryBot)
        FactoryBot.definition_file_paths << File.expand_path('../../../spec/factories', __FILE__)
      end
    end
    config.active_storage.draw_routes = true
  end
end
