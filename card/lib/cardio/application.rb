# -*- encoding : utf-8 -*-

require 'rails'

Bundler.require :default, *Rails.groups if defined?(Bundler)

module Cardio
  class Application < ::Rails::Application

    initializer :connect_on_load, after: :load_active_suport do
      ActiveSupport.run_load_hooks(:before_card)
      ActiveSupport.on_load(:active_record) do
        Cardio.connect_on_load
        ActiveRecord::Base.establish_connection(::Rails.env.to_sym)
        ActiveSupport.run_load_hooks(:before_card)
      end
    end
  end
end
