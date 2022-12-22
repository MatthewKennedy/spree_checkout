module Spree
  module PermittedAttributes
    @@store_attributes << [:checkout_shipping_instructions, :checkout_coupon_codes_enabled]
  end
end
