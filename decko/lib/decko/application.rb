
warn "DREQ #{__FILE__}:#{__LINE__}"
require "cardio/application"
warn "DREQ2 #{__FILE__}:#{__LINE__}"

module Decko
  class Application < Cardio::Application
    class << self
      def inherited base
warn "DIBASE #{__FILE__}:#{__LINE__} #{base} Sf:#{self}"
        Rails.app_class = base
      end
    end

    def configure &block
warn "DCONF0 #{__FILE__}:#{__LINE__} bk:#{block_given?} Sf:#{self}"
      if block_given?
        class_eval(&block)
        #super
warn "DCONF0 #{__FILE__}:#{__LINE__} Sf:#{self}"
        config.configure &block
warn "DCONF1 #{__FILE__}:#{__LINE__} Sf:#{self}"
      end
warn "DCONF2 #{__FILE__}:#{__LINE__} Sf:#{self}"
    end

    initializer :set_load_path do
    #initializer :deck_application_config, after: :set_load_path do
warn "DINIT0 #{__FILE__}:#{__LINE__} Sf:#{self} before_set_load_path"
      ActiveSupport.run_load_hooks(:before_set_load_path)
warn "DINIT0 #{__FILE__}:#{__LINE__} Sf:#{self} before_set_load_path"
      Cardio.config
warn "DINIT0 #{__FILE__}:#{__LINE__} Sf:#{self} cfg:#{config}"
      ActiveSupport.run_load_hooks(:after_set_load_path)
warn "DINIT0 #{__FILE__}:#{__LINE__} Sf:#{self} before_set_load_path"
    end

    #initializer :deck_application_config, before: :set_load_path do
#warn "DINIT0 #{__FILE__}:#{__LINE__} Sf:#{self} before_set_load_path"
      #ActiveSupport.run_load_hooks(:set_load_path)
    #end

    initializer before: :load_config_initializers do
warn "DINIT1 #{__FILE__}:#{__LINE__} before_set_autoload_paths"
      #ActiveSupport.run_load_hooks(:before_set_autoload_paths)
warn "DINIT2 #{__FILE__}:#{__LINE__} load_config_initializers"
      #ActiveSupport.run_load_hooks(:load_config_initializers)
warn "DINIT3 #{__FILE__}:#{__LINE__} environment_initialize"
      #ActiveSupport.run_load_hooks(:environment_initialize)
warn "DINIT4 #{__FILE__}:#{__LINE__} add_routing_paths"
      #ActiveSupport.run_load_hooks(:add_routing_paths)
warn "DINIT5 #{__FILE__}:#{__LINE__}"
    end
  end
end

