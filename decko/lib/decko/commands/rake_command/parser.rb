# -*- encoding : utf-8 -*-
require "optparse"

module Decko
  module Commands
    class RakeCommand
      class Parser < OptionParser
        def initialize command, opts
          super() do |parser|
            parser.banner = "Usage: decko #{command} [options]\n\n" \
                          "Run decko:#{command} task on the production "\
                          " database specified in config/database.yml\n\n"
            parser.on("--deck [DECK]", "-k",
                      "#{command} use deck (default 1)") do |deck|
              opts[:deck] = deck || 1
            end
            parser.on("--production", "-p",
                      "#{command} production database (default)") do
              opts[:envs] = ["production"]
            end
            parser.on("--test", "-t",
                      "#{command} test database") do
              opts[:envs] = ["test"]
            end
            parser.on("--development", "-d",
                      "#{command} development database") do
              opts[:envs] = ["development"]
            end
            parser.on("--all", "-a",
                      "#{command} production, test, and development database") do
              opts[:envs] = %w(production development test)
            end
          end
        end
      end
    end
  end
end
