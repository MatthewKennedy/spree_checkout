module Spree
  module MenuDecorator
    Spree::Menu::MENU_LOCATIONS << 'Checkout Footer'
    Spree::Menu::MENU_LOCATIONS_PARAMETERIZED << 'checkout_footer'

    ::Spree::Menu.prepend self if ::Spree::Menu.included_modules.exclude?(self)
  end
end
