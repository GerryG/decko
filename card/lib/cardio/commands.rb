# add method in? to Object class
require "active_support/core_ext/object/inclusion"
#require 'cardio/application_record'

require "rake"
def load_rake_tasks
  require "./config/environment"
  Cardio::Application.load_tasks
end

#require "cardio"
# if anything left, include in Decko
# should go to card_command.rb
=begin
module Cardio
  module Commands

    CARD_TASK_COMMANDS = %w(card add add_remote refresh_machine_output
                         reset_cache reset_tmp update merge merge_all
                         assume_card_migrations clean clear dump emergency
                         load seed reseed supplement update seed reseed
                         load update).freeze

    module ClassMethods
      def run_rspec
        require "cardio/commands/rspec_command"
        RspecCommand.new(ARGV).run
      end

      def run_task command
        require "cardio/commands/rake_command"
        RakeCommand.new(['card', command]*':', ARGV).run
      end
    end

    class << self
      include ClassMethods
    end
  end
end

ARGV << "--help" if ARGV.empty?

ARGV.unshift 'card' if ARGV.first == '-T'
command = ARGV.first
command = ALIAS[command] || command

  ARGV.shift
  lookup = command
  lookup = $1 if command =~ /^([^:]+):/
  case lookup
  when "--version", "-v"
    puts "Card #{Card::Version.release}"
  when 'rspec'
    Cardio::Commands.run_rspec
  when *Cardio::Commands::CARD_TASK_COMMANDS
    Cardio::Commands::RakeCommand.run_task command
  else
    puts "Error: Command not recognized" unless command.in?(["-h", "--help"])
    puts <<-EOT
  Usage: card COMMAND [ARGS]

  The most common card commands are:
   seed        Create and seed the database specified in config/database.yml

   server      Start the Rails server (short-cut alias: "s")
   console     Start the Rails console (short-cut alias: "c")
   dbconsole   Start a console for the database specified in config/database.yml
             (short-cut alias: "db")

  For core developers
   rspec        Run rspec tests (short-cut alias: "rs")
   update       Run card migrations
   load         Load bootstrap data into database

  In addition to those, there are the standard rails commands:
   generate     Generate new code (short-cut alias: "g")
   application  Generate the Rails application code
   destroy      Undo code generated with "generate" (short-cut alias: "d")
   benchmarker  See how fast a piece of code runs
   profiler     Get profile information from a piece of code
   plugin       Install a plugin
   runner       Run a piece of code in the application environment (short-cut alias: "r")

All commands can be run with -h (or --help) for more information.
  EOT
  exit(1)
end

