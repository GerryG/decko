class Card
  # retrieve card from cache or database, or (where needed) instantiate new card
  class Fetch
    include Retrieve
    include Results
    include Store

    attr_reader :card, :mark, :opts

    # see arg options in all/fetch
    def initialize *args
      normalize_args args
      absolutize_mark
      validate_opts!
    end

    def retrieve_or_new
      retrieve_existing
      update_cache
      results
    end

    def local_only?
      opts[:local_only]
    end

    def skip_modules?
      opts[:skip_modules]
    end

    def normalize_args args
      @opts = args.last.is_a?(Hash) ? args.pop : {}
      @mark = Card.id_or_name args
    end

    def absolutize_mark
      return unless mark.name? && (supercard = opts.dig(:new, :supercard))
      @mark = mark.absolute_name supercard.name
    end

    def validate_opts!
      return unless opts[:new] && opts[:skip_virtual]
      raise Card::Error, "fetch called with new args and skip_virtual"
    end

    def look_in_trash?
      @opts[:look_in_trash]
    end

    def skip_type_lookup?
      # if opts[:new] is not empty then we are initializing a variant that is
      # different from the cached variant
      # and can postpone type lookup for the cached variant
      # if skipping virtual no need to look for actual type
      opts[:skip_virtual] || opts[:new].present? || opts[:skip_type_lookup]
    end
  end
end
