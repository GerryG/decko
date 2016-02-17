class Card
  # The process of writing a card change to the database is divided into
  # 8 stages that are grouped in 3 phases.
  #
  # 'validation phase'
  #   * initialize stage
  #   * prepare_to_validate stage
  #   * validate stage
  #
  # 'storage phase'
  #   * prepare_to_store stage
  #   * store stage
  #   * finalize stage
  #
  # 'integration phase'
  #   * integrate stage
  #   * integrate_with_delay stage
  #
  #
  module Stage
    STAGES = [:initialize, :prepare_to_validate, :validate, :prepare_to_store,
              :store, :finalize, :integrate, :integrate_with_delay].freeze
    STAGE_INDEX = {}
    STAGES.each_with_index do |stage, i|
      STAGE_INDEX[stage] = i
    end
    STAGE_INDEX.freeze

    def stage_symbol index
      case index
      when Symbol
        return index if STAGE_INDEX[index]
      when Integer
        return STAGES[index] if index < STAGES.size
      end
      raise Card::Error, "not a valid stage index: #{index}"
    end

    def stage_index stage
      case stage
      when Symbol then
        return STAGE_INDEX[stage]
      when Integer then
        return stage
      else
        raise Card::Error, "not a valid stage: #{stage}"
      end
    end

    def stage_ok? opts
      stage && (
      (opts[:during] && in?(opts[:during])) ||
        (opts[:before] && before?(opts[:before])) ||
        (opts[:after] && after?(opts[:after])) ||
        true # no phase restriction in opts
      )
    end

    def before? allowed_phase
      STAGE_INDEX[allowed_phase] > STAGE_INDEX[stage]
    end

    def after? allowed_phase
      STAGE_INDEX[allowed_phase] < STAGE_INDEX[stage]
    end

    def in? allowed_phase
      (allowed_phase.is_a?(Array) && allowed_phase.include?(stage)) ||
        allowed_phase == stage
    end
  end
end
