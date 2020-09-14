# decko-gem/rails/channels/decko/card_channel.rb

module Decko
  class CardChannel < ApplicationCable::Channel
    attr_accessor :card, :channel_name

    def subscribed
      stream_from channel_name if channel_name
    end

    def receive data
    end
 
  private
    # maybe maybe add to Card as #channel_name
    def channel_name
      @channel_name = if @channel_name.nil? && @card = load_card(params[:card])
          "card_channel_#{card.key}"
        else
          @card = false
        end
    end
  end
end
