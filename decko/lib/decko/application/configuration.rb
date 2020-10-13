
warn "DCREQ #{__FILE__}:#{__LINE__}"
require "cardio/application"
warn "DCREQ2 #{__FILE__}:#{__LINE__}"

module Decko
  class Application
    class Configuration < Decko::Railtie::Configuration
    class << self
      def inherited base
warn "DCIBASE #{__FILE__}:#{__LINE__} #{base} Sf:#{self}"
        Rails.app_class = base
      end
    end
  end
end

