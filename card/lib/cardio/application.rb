# -*- encoding : utf-8 -*-

require "rails"
#require "application_job"

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < ::Rails::Application
    class << self
      def inherited base
warn "CIBASE #{__FILE__}:#{__LINE__} #{base} Sf:#{self}"
        Rails.app_class = base
warn "CIBASE #{__FILE__}:#{__LINE__} #{base} Sf:#{config}"
      end
    end

    def configure &block
warn "CCONF0 #{__FILE__}:#{__LINE__} bk:#{block_given?} Sf:#{self}"
      if block_given?
        class_eval(&block)
warn "CCONF1 #{__FILE__}:#{__LINE__} Sf:#{self}"
        #config.configure &block
warn "CCONF2 #{__FILE__}:#{__LINE__} Sf:#{self}"
      end
    end

    ENVCONF = "lib/card/config/environments"

    initializer :connect_on_load, after: :load_active_record do
warn "CINIT4 #{__FILE__}:#{__LINE__} Sf:#{self}"
      ActiveSupport.run_load_hooks(:before_card)
      ActiveSupport.on_load(:active_record) do
warn "CINIT4 #{__FILE__}:#{__LINE__}"
        Cardio.connect_on_load
warn "CINIT4 #{__FILE__}:#{__LINE__}"
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
      end
    end
  end
end
