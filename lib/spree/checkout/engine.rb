require_relative 'configuration'

module Spree
  module Checkout
    class Engine < ::Rails::Engine
      initializer 'spree.checkout.environment', before: :load_config_initializers do |_app|
        Spree::Checkout::Config = Spree::Checkout::Configuration.new
      end
    end
  end
end
