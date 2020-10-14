
if ARGV.first != "new"
  require 'cardio/script_loader'
  # this will require <base>/commands/<command>_command
  require Cardio::ScriptLoader.command_path 'card'

else
  require "rails/generators"
  require File.expand_path("../../generators/deck/deck_generator", __FILE__)

  ARGV.shift

  Decko::Generators::Deck::DeckGenerator.start
end

