module Decko
  class Deck

    attr_reader :root, :application, :gem_root, :config, :paths

    def inspect
      "<Deck: r:#{root}, gr:#{gem_root}, cfg:#{config}, pth:#{paths.inspect} A:#{application.inspect}>"
    end

    def application= app
      return unless @application = app
      @config ||= app.config
      @paths ||= app.paths
      app
    end

    def initialize args
      @root = args[:root]
      @gem_root = args[:gem_root]
      application = args[:application]
      self
    end
  end
end
