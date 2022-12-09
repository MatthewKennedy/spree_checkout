module Spree
  module Variants
    class Find
      def initialize(variants: nil, options: nil, return_object: false)
        @variants       = variants
        @options        = options
        @return_object  = return_object
      end

      def execute
        find_by_option_value_ids
      end

      private

      def option_value_ids?
        @options.present?
      end

      def find_by_option_value_ids
        return @variants unless option_value_ids?

        vars = @variants.
               joins(:option_values).
               where(option_values: { id: @options }).
               group('spree_variants.id').
               having('COUNT(distinct option_values.id) = ?', @options.count)

        if @return_object
          vars.first
        else
          vars.map(&:id)
        end
      end
    end
  end
end
