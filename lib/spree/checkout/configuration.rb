module Spree
  module Checkout
    class Configuration < Preferences::Configuration
      preference :shipping_instructions, :boolean, default: false
      preference :coupon_codes_enabled, :boolean, default: true
      preference :remember_me_enabled, :boolean, default: true
    end
  end
end
