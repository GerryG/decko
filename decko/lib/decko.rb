
module Decko
  mattr_accessor :default_deck

  def self.application
    ::Rails.application
  end

  def Decko.card_gem_root
    @@card_gem_root ||= File.expand_path('../../../card', __FILE__)
  end

  DECKO_GEM_ROOT = File.expand_path("../..", __FILE__)
end
