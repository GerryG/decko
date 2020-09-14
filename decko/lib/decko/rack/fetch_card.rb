require 'rack'
#require 'decko/response'

module Decko
  module Rack
    # implement Rack API, initialize takes the next app in the stack that is called unless handled here. If the card is fetched here, we still call the app unless the card is not fetched or created.
    class FetchCard
      include Decko::Response

      attr_accessor :app

require 'pry'
      def initialize(app)
#binding.pry
        self.app = app
      end

      # process in this middleware:
      #   try to fetch, or new a Card here, or NotFound status
      #   Create a Rack app for the main app (Card stuff) can recursively fetch cards handled in this middleware.
      def call(env)
        req = ::Rack::Request.new(env)

        if not_handled?(req)
binding.pry
          return app.call(env)
        elsif fetch_card(req)
        elsif new_card(req)
        else
          return [404, {}, ""]
        end
        req.middleware_card = FetchCard.new(nil)
        app.call(env)
      end
    private

#   setup(req) unless [:asset].include?(req.action)
#   authenticate(req) unless [:asset].include?(req.action)
#   load_mark(req) unless [:read].include?(req.action)
#   load_card(req) unless [:asset].include?(req.action)
#   load_card(req) unless [:asset].include?(req.action)

=begin
  def setup(req)
    Card::Machine.refresh_script_and_style unless params[:explicit_file]
    Card::Cache.renew
    Card::Env.reset controller: self
  end

  def authenticate
    Card::Auth.signin_with token: params[:token], api_key: params[:api_key]
  end

  def load_mark
    params[:mark] = interpret_mark params[:mark]
  end

  def load_card
    @card = Card.controller_fetch params
    raise Card::Error::NotFound unless card
    record_as_main
  end

=end

      def not_handled?(req)
        true
      end

      def fetch_card(req)
warn "fetch #{req.inspect}"
warn "fetch2 #{req.params.inspect}"
        true
      end

      def new_card(req)
        false
      end
    end
  end
end
