require 'active_support'

module Decko

  mattr_accessor :default_deck

  def Decko.card_gem_root
    @@card_gem_root ||= File.expand_path('../../../card', __FILE__)
  end

  class Deck

    attr_reader :root, :application, :gem_root, :config, :paths

    def inspect
      "<Deck: r:#{root}, gr:#{gem_root}, cfg:#{config}, pth:#{paths.inspect} A:#{application.inspect}>"
    end

    def application= app
      return unless @application = app
      @config = app.config
      @paths = app.paths
      app
    end

    def initialize args
      @root = args[:root]
      @gem_root = args[:gem_root]
      application = args[:application]
      self
    end
  end

  DECKO_GEM_ROOT = File.expand_path("../..", __FILE__)

end
