require File.expand_path("../command", __FILE__)
# require "pry"

module Decko
  module Commands
    class RakeCommand < Command
      def initialize rake_task, args={}
        @task = rake_task
        if args.is_a? Array
          opts = {args: args}
          Parser.new(rake_task, opts).parse!(args)
        else
          opts = args
        end
        @deck = opts[:deck]
        @envs = Array(opts[:envs])
      end

      def run
        commands.each do |cmd|
          puts cmd
          # exit_with_child_status cmd

          result = `#{cmd}`
          process = $?
          puts result
          exit process.exitstatus unless process.success?
        end
      end

      def commands
        task_cmd = "bundle exec rake #{@task}"
        return [task_cmd] if !@envs || @envs.empty?
        @envs.map do |env|
          deckopt = @deck ? "DECKO_DECK_ID=@deck " : ''
          "env RAILS_ENV=#{env} #{deckopt}#{task_cmd}"
        end
      end
    end
  end
end

require File.expand_path("../rake_command/parser", __FILE__)
