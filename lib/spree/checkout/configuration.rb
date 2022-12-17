module Spree
  module Checkout
    class Configuration < Preferences::Configuration
      preference :always_put_site_name_in_title, :boolean, default: true
      preference :shipping_instructions, :boolean, default: false
      preference :coupon_codes_enabled, :boolean, default: true # Determines if we show coupon code form at cart and checkout
      preference :layout, :string, default: 'spree/layouts/spree_application'
      preference :locale, :string, default: nil
      preference :remember_me_enabled, :boolean, default: true
      preference :title_site_name_separator, :string, default: '-' # When always_put_site_name_in_title is true, insert a separator character before the site name in the title
    end
  end
end
