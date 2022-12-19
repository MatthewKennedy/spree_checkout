require_relative "configuration"

module Spree
  module Checkout
    class Engine < ::Rails::Engine
      engine_name "spree_checkout"

      initializer "spree.checkout.environment", before: :load_config_initializers do |_app|
        Spree::Checkout::Config = Spree::Checkout::Configuration.new
      end

      def self.activate
        Dir.glob(File.join(File.dirname(__FILE__), "../../../app/**/spree/*_decorator*.rb")).sort.each do |c|
          Rails.application.config.cache_classes ? require(c) : load(c)
        end
      end

      config.to_prepare(&method(:activate).to_proc)
    end
  end
end
