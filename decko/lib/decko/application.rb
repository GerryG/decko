# -*- encoding : utf-8 -*-

require "decko/engine"
require "card/application"
djar = "delayed_job_active_record"
require djar if Gem::Specification.find_all_by_name(djar).any?

module Decko
  class Application < Card::Application
    class << self
      def inherited base
        super
        Rails.app_class = base
        add_lib_to_load_path!(find_root(base.called_from))
        ActiveSupport.run_load_hooks(:before_configuration, base.instance)
      end
    end

    def add_path paths, path, options={}
      root = options.delete(:root) || Decko.gem_root
      options[:with] = File.join(root, (options[:with] || path))
      paths.add path, options
    end

    def config
      @config ||= begin
        config = super

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

        config.autoloader = :zeitwerk
        config.load_default = "6.0"
        config.i18n.enforce_available_locales = true
        # config.active_record.raise_in_transactional_callbacks = true

        config.allow_concurrency = false
        config.assets.enabled = false
        config.assets.version = "1.0"

        config.filter_parameters += [:password]

        # Rails.autoloaders.log!
        Rails.autoloaders.main.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
        config
      end
    end

    def paths
      @paths ||= begin
        paths = super
        Cardio.set_paths paths

        paths.add "files"

        paths["app/models"] = []
        paths["app/mailers"] = []

        unless paths["config/routes.rb"].existent.present?
          add_path paths, "config/routes.rb",
                   with: "rails/application-routes.rb"
        end

        paths
      end
    end
  end
end
