
require "rails/all"
require "cardio"

# TODO: Move these to modules that use them
require "htmlentities"
require "recaptcha"
require "coderay"
require "haml"
require "kaminari"
require "bootstrap4-kaminari-views"
require "diff/lcs"
require "builder"

require "decko"

module Decko

  class << self

  private

    def locate_gem name
      spec = Bundler.load.specs.find { |s| s.name == name }
      unless spec
        raise GemNotFound, "Could not find gem '#{name}' in the current bundle."
      end
      return File.expand_path("../../../", __FILE__) if spec.name == "bundler"
      spec.full_gem_path
    end
  end

  Decko.card_gem_root ||= locate_gem "card"

  class Engine < ::Rails::Engine
    ddeck = Decko.default_deck ||= Deck.new(
        root: Rails.root,
        application: Rails.application,
        gem_root: DECKO_GEM_ROOT
      )
    paths.add "app/controllers",  with: "rails/controllers", eager_load: true
    paths.add "gem-assets",       with: "rails/assets"
    paths.add "config/routes.rb", with: "rails/engine-routes.rb"
    paths.add "lib/tasks", with: "#{ddeck.gem_root}/lib/decko/tasks",
                           glob: "**/*.rake"
    paths["lib/tasks"] << "#{::Cardio.gem_root}/lib/card/tasks"
    paths.add "lib/decko/config/initializers",
              with: File.join(ddeck.gem_root, "lib/decko/config/initializers"),
              glob: "**/*.rb"

    initializer "decko.engine.load_config_initializers",
                after: :load_config_initializers do
      paths["lib/decko/config/initializers"].existent.sort.each do |initializer|
        load(initializer)
      end
    end

    initializer "engine.copy_configs",
                before: "decko.engine.load_config_initializers" do
      # this code should all be in Decko somewhere, and it is now, gem-wize
      # Ideally railties would do this for us; this is needed for both use cases
      Engine.paths["request_log"]   = Decko.default_deck.paths["request_log"]
      Engine.paths["log"]           = Decko.default_deck.paths["log"]
      Engine.paths["lib/tasks"]     = Decko.default_deck.paths["lib/tasks"]
      Engine.paths["config/routes.rb"] = Decko.default_deck.paths["config/routes.rb"]
    end

    initializer :connect_on_load do
      ActiveSupport.on_load(:active_record) do
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
      end
      # ActiveSupport.on_load(:after_initialize) do
      #   # require "card" if Cardio.load_card?
      #   Card if Cardio.load_card?
      # rescue ActiveRecord::StatementInvalid => e
      #  ::Rails.logger.warn "database not available[#{::Rails.env}] #{e}"
      # end
    end
  end
end
