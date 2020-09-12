# -*- encoding : utf-8 -*-

# Decko's only controller.
class CardController < ApplicationController
  include ::Card::Env::Location
  include ::Recaptcha::Verify #FIXME make Recaptcha optional/pluggable
  include ::Decko::Response

  layout nil
  attr_reader :card

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #  PRIVATE METHODS

  private

  #-------( FILTERS )

  before_action :setup, except: [:asset]
  before_action :authenticate, except: [:asset]
  before_action :load_mark, only: [:read]
  before_action :load_card, except: [:asset]
  before_action :load_action, only: [:read]
  before_action :refresh_card, only: [:create, :update, :delete]

  def setup
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

  def load_action
    card.select_action_by_params params
    card.content = card.last_draft_content if params[:edit_draft] && card.drafts.present?
  end

  # TODO: refactor this away this when new layout handling is ready
  def record_as_main
    Card::Env[:main_name] = params[:main] || card&.name || ""
  end

  def refresh_card
    @card = card.refresh
  end

  class << self
    def rescue_from_class *klasses
      klasses.each do |klass|
        rescue_from(klass) { |exception| handle_exception exception }
      end
    end

    def rescue_all?
      Cardio.config.rescue_all_in_controller
    end
  end

  rescue_from_class(*Card::Error::UserError.user_error_classes)
  rescue_from_class StandardError if rescue_all?
end
