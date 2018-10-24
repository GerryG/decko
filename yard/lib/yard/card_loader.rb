
require "active_support"
require "active_support/core_ext/string/inflections"

# Helper for decoding module paths. Set patterns supported are hard coded here
#
# Path format: set/<name>/<set-key>/<0-N 'parameter cards'>[/<freename>].rb
#
class YARD
    class CardLoader

        SET_PATTERNS = {
           "Abstract"      => 1,
           "All"           => 1,
           "Right"         => 1,
           "Rstar"         => 1,
           "Self"          => 1,
           "Type"          => 1,
           "TypePlusRight" => 2
        }
        PREFIX = %w[Card Set]

        attr_reader :path, :modname, :setkey, :selectors, :namespace

        def initialize path
            path.sub!(/\.(\w+)$/, '') && ext = $1
            @path = path
            parts = path.split("/")
            modn = parts.index("mod")
    	#log.warn "P:#{parts.inspect}, #{modn}"
            if ext == "rb" && !modn.nil? && parts[modn+2] == "set"
                @setkey = parts[modn+3].camelize
                nselects = SET_PATTERNS[setkey]
                if !nselects.nil? && parts.size >= modn+4+nselects
                    @modname = parts[modn+1]
                    @selectors = parts[modn+4..modn+3+nselects].map(&:camelize)
                    @namespace = [*PREFIX, setkey, *selectors]*"::"
    #            else
    #                log.warn "sk:#{setkey}, #{nselects} Args: #{parts.size} >= #{modn} +4+nselects"
                end
    #        else
    #            log.warn "no idx #{modn.inspect}, set:#{modn && parts[modn+2].inspect}, #{parts.inspect}"
            end
        end

        def format_class format
            if @format_class.nil?
               format = format.to_sym
               format = :html_format if format == :email
               @format_class = "#{namespace}::#{format.to_s.camelize}Format"
            end
            @format_class
        end
    end
end
