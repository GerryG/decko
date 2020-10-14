
require 'cardio'

module Decko
  DECKO_GEM_ROOT = File.expand_path("../..", __FILE__)

  class << self
    include Cardio::CardClassMethods

    def gem_root
      DECKO_GEM_ROOT
    end
  end
end
