require "rbconfig"
require "pathname"

module ScriptLoader
  RUBY = File.join(*RbConfig::CONFIG.values_at("bindir", "ruby_install_name")) +
         RbConfig::CONFIG["EXEEXT"]
  # replace with current cli.rb
  APP_DECKO = File.join("config", "application.rb")

  def self.find_app_config
    cwd = Dir.pwd
    return unless in_decko_application? || in_decko_application_subdirectory?
    return File.join(cwd, APP_DECKO)
    Dir.chdir("..") do
      # Recurse in a chdir block: if the search fails we want to be sure
      # the application is generated in the original working directory.
      exec_script_decko! unless cwd == Dir.pwd
    end
  rescue SystemCallError
    # could not chdir, no problem just return
  end

  def self.in_decko_application?
    File.exist?(APP_DECKO)
  end

  def self.in_decko_application_subdirectory? path=Pathname.new(Dir.pwd)
    File.exist?(File.join(path, APP_DECKO)) ||
      !path.root? && in_decko_application_subdirectory?(path.parent)
  end
end

# If we are inside a Decko/Card application (have a parent with
# config/application.rb, therefore any rails and use card commands
# otherwise we are decko new and decko/commands.rb should handle it.
# The first case here is in app, replaces script_loader method
if defined?(APP_CONF) || APP_CONF = ScriptLoader.find_app_config
  require APP_CONF
  require File.expand_path("../boot", APP_CONF)
  require 'decko/commands'
end

 require "rails/ruby_version_check"
 Signal.trap("INT") { puts; exit(1) }

#if ARGV.first == 'plugin'
#  ARGV.shift
#  require 'decko/commands/plugin_new'
#else
  require "decko/commands/application"
#end

