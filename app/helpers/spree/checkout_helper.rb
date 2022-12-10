module Spree
  module CheckoutHelper
    def spree_checkout_svg_tag(file_name, options = {})
      prefixed_file = "spree/checkout/#{file_name}"

      spree_checkout_svg_tag(prefixed_file, options)
    end
  end
end
