# -*- encoding : utf-8 -*-
# Load RSpec and Capybara

#require 'rspec'
#=begin
require 'capybara/rspec'
require 'capybara/dsl'

# Configure RSpec
RSpec.configure do |config|
  # Mixin the Capybara functionality into Rspec
  config.include Capybara::DSL
  config.order = 'default'
end

# Define the application we're testing
#def app
  # Load the application defined in config.ru
  #Rack::Builder.parse_file('config.ru').first
#  Decko.application
#end
#=end
Capybara.app = Rack::Builder.parse_file('config.ru').first

module Decko
  # for use in REST API specs
  module HtmlSpecMethods
    def with_api_key_for usermark
      key_card = Card.fetch [usermark, :account, :api_key], new: {}
      key_card.content = "asdkfjh1023498203jdfs"
      Card::Auth.as_bot { key_card.save! }
      yield key_card.content
    end
  end

  # for use in REST API specs
  module HtmlSpecHelper
    def self.describe_api &block
      RSpec.describe ApplicationController, type: :request do
        #routes { Decko.application.routes }
        include Capybara::DSL
        include HtmlSpecMethods
        instance_eval(&block)
      end
    end
  end
end
