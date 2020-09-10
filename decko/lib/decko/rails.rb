DECKO_RAILS_GEM_ROOT = File.expand_path("../../..", __FILE__)

module Decko
  if defined? ::Rails::Railtie
    class Railtie < ::Rails::Railtie
      rake_tasks do |_app|
        load("card/tasks/card.rake")
        load("card/tasks/card/migrate.rake")
        load("card/tasks/card/create.rake")
        load("decko/tasks/db.rake")
        load("decko/tasks/decko/seed.rake")
        load("decko/tasks/decko.rake")
        load("decko/tasks/cucumber.rake")
      end
    end
  end
end
