require "rbconfig"
require "pathname"
require "cardio"

module Cardio
  module ScriptLoader
    RUBY = File.join(*RbConfig::CONFIG.values_at(
            "bindir", "ruby_install_name") ) + RbConfig::CONFIG["EXEEXT"]

    PATH_ALIAS = { 'cardio' => 'card', 'decko' => 'deck' }

    class <<self
      def script_file
        File.join("script", @command.to_s)
      end

      def script_dir?
        Pathname.new("script").exist?
      end

      attr_reader :command

      def base
        @base ||= begin
          @command ||= ((cmd = $0) =~ /\/([^\/]+)$/) ? $1 : cmd
          @command = PATH_ALIAS[@command] unless PATH_ALIAS[@command].nil?
          case @command
            when 'deck'; 'decko'
            #when 'card'; 
            else         'cardio'
            end
        end
      end

      # If we are NOT inside a Card application this method performs calls
      # the block when given on the parsed scriptname.
      # Parses command to run and require base from the command and aliases
      def exec_script! cmd=nil, &block
        @command = cmd unless cmd.nil?
        base # make sure base/command get set from $0
        path = Pathname.new(cwd = Dir.pwd)
        unless path.root? || script_dir?
          return (yield(@base) if block_given?)
        end
        exec RUBY, script_file, *ARGV
        Dir.chdir("..") do
          # Recurse in a chdir block: if the search fails we want to be sure
          # the application is generated in the original working directory.
          exec_script! unless cwd == Dir.pwd
        end
      rescue SystemCallError
        # could not chdir, no problem just return
      end

      def command_path cmd=nil
        @command = cmd unless cmd.nil?
        "#{base}/commands/#{@command}_command"
      end
    end
  end
end

Cardio::ScriptLoader.exec_script! do |base|

  require "rails/ruby_version_check"
  Signal.trap("INT") { puts; exit(1) }

  # if base == 'plugin'
  #  ARGV.shift
  #  require "#{base}/commands/plugin_new"
  # else

  # end
  # FIXME: if path/... not there, use "cardio" (skip aliasing above?)
  #require "#{base}/commands/application"
end
