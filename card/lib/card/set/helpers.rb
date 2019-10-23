class Card
  module Set
    module Helpers
      def shortname
        first = 2 # shortname eliminates Card::Set
        last = first + num_set_parts(pattern_code)
        set_name_parts[first..last].join "::"
      end

      def underscore
        shortname.tr(":", "_").underscore
      end

      def num_set_parts pattern_code
        return 1 if pattern_code == :abstract

        Pattern.find(pattern_code).anchor_parts_count
      end

      def set_name_parts
        @set_name_parts ||= name.split "::"
      end

      def pattern_code
        @pattern_code ||= set_name_parts[2].underscore.to_sym
      end

      # handles all_set?, abstract_set?, type_set?, etc.
      def method_missing method_name, *args
        if (matches = method_name.match(/^(?<pattern>\w+)_set\?$/))
          pattern_code == matches[:pattern].to_sym
        else
          super
        end
      end
    end
  end
end
