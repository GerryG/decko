# -*- encoding : utf-8 -*-

#require "decko/engine"
require "cardio/application/configuration"

Bundler.require :default, *Rails.groups

module Decko
  module Railtie
    class Application < ::Rails::Railtie::Application
      class Configuration < Decko::Engine::Application::Configuration

warn "RAPPCONF0 #{__LINE__} #{self}"
        PATH = "lib/decko/config/environments"

#        def configure &block

warn "RAPPCONF1 #{__LINE__} #{self}"
          super if block_given?
warn "RAPPCONF2 #{__LINE__} #{self}"

          paths.add "config/initializers", glob: "**/*.rb",
            with: File.join(Decko.gem_root, "lib/decko/config/initializers")

          paths.add "lib", root: Decko.gem_root
          config.autoload_paths += Dir["#{Decko.gem_root}/lib"]

          config.load_defaults "6.0"
          paths.add "lib", root: Decko.gem_root
          Cardio.set_load_path

          config.active_job.queue_adapter = :delayed_job

          # any config settings below:
          # (a) do not apply to Card used outside of a Decko context
          # (b) cannot be overridden in a deck's application.rb, but
          # (c) CAN be overridden in an environment file

          # therefore, in general, they should be restricted to settings that
          # (1) are specific to the web environment, and
          # (2) should not be overridden
          # ..and we should address (c) above!

          # general card settings (overridable and not) should be in cardio.rb
          # overridable decko-specific settings don't have a place yet
          # but should probably follow the cardio pattern.

          config.i18n.enforce_available_locales = true

          config.allow_concurrency = false
          config.assets.enabled = false
          config.assets.version = "1.0"
          # config.active_record.raise_in_transactional_callbacks = true

          config.filter_parameters += [:password]

          # Rails.autoloaders.log!
          Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
          # paths configuration

          paths.add "files"

          paths["app/models"] = []
          paths["app/mailers"] = []

          unless paths["config/routes.rb"].existent.present?
            paths.add "config/routes.rb", with: "rails/application-routes.rb"
          end

          path = File.join(Decko.gem_root, PATH, "#{Rails.env}.rb")
          paths.add PATH, with: path
          paths[PATH].existent.each do |environment|
            require environment
          end
        end
#      end
    end
  end
end
