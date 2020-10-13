# -*- encoding : utf-8 -*-

require "rails"

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application
    class Configuration < ::Rails::Application::Configuration

      ENVCONF = "lib/card/config/environments"

      def configure &block
        super if (block_given?)

        Cardio.autoload_paths

        Cardio.default_configs

        #Rails.autoloaders.log!

        paths.add "config/initializers", glob: "**/*.rb",
          with: File.join(Cardio.gem_root, "lib/card/config/initializers")
        paths["config/initializers"].existent.sort.each do |initializer|
          load(initializer)
        end

        Rails.autoloaders.main&.ignore(File.join(Cardio.gem_root, "lib/card/seed_consts.rb"))
        path = File.join(Cardio.gem_root, ENVCONF, "#{Rails.env}.rb")
        paths.add ENVCONF, with: path, glob: "#{Rails.env}.rb"
        paths[ENVCONF].existent.each do |environment|
          require environment
        end
      end
    end
  end
end
