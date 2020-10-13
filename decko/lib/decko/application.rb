require "cardio/application"

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
        Rails.app_class = base
      end
    end
  end
end

