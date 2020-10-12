# -*- encoding : utf-8 -*-

command = (cmd=$0) =~ /\/([^\/]+)$/ ? $1 : cmd

if command != 'new'
  require 'cardio/script_loader'

=begin
  module Cardio
    module Commands
      require 'rails'

      class Application < ::Rails::Application
        def inherited base
warn "CARDCMD APP #{__LINE__} #{base} #{self}"
          Rails.app_class = base
        end
        initializer :set_app_path do
warn "CARDCMD APP #{__LINE__}"
        end
      end
    end
  end
=end

  # this will require <base>/commands/<command>_command
  require Cardio::ScriptLoader.command_path
else
  ARGV[0] = '--help'
  require "cardio/commands"
end

