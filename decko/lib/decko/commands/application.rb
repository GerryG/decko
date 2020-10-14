require "rails/generators"
require File.expand_path("../../generators/deck/deck_generator", __FILE__)

if ARGV.first != "new"
  #require "decko/application"
  require "cardio/commands"
else
  ARGV.shift

  Decko::Generators::Deck::DeckGenerator.start
end
