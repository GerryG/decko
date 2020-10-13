
if ARGV.first != "new"
  require 'cardio/commands' # .../commands/card_command ?
  module Cardio
    module Commands
      class Application < Cardio::Commands::Application
      end
    end
  end

else
  require "rails/generators"
  require File.expand_path("../../generators/deck/deck_generator", __FILE__)

  ARGV.shift

  Decko::Generators::Deck::DeckGenerator.start
end

