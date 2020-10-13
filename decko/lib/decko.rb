# -*- encoding : utf-8 -*-

require 'cardio'

module Decko
  DECKO_GEM_ROOT = File.expand_path("../..", __FILE__)

  class << self
    include Cardio::CardClassMethods
    include Cardio::ConfigClassMethods

    def gem_root
      DECKO_GEM_ROOT
    end

    def read_only?
      !ENV["DECKO_READ_ONLY"].nil?
    end
  end
end
