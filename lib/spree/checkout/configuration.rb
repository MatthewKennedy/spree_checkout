module Spree
  module Checkout
    class Configuration < Preferences::Configuration
      preference :shipping_instructions, :boolean, default: false
    end
  end
end
