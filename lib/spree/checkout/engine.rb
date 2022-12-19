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

      def self.api_available?
        @@api_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Spree::Api::Engine")
      end

      def self.backend_available?
        @@backend_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Spree::Backend::Engine")
      end

      def self.frontend_available?
        @@frontend_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Spree::Frontend::Engine")
      end

      def self.emails_available?
        @@emails_available ||= ::Rails::Engine.subclasses.map(&:instance).map { |e| e.class.to_s }.include?("Spree::Emails::Engine")
      end

      if backend_available?
        paths["app/controllers"] << "lib/controllers/backend"
        paths["app/views"] << "lib/views/backend"
      end

      if frontend_available?
        paths["app/controllers"] << "lib/controllers/frontend"
        paths["app/views"] << "lib/views/frontend"
      end

      if api_available?
        paths["app/controllers"] << "lib/controllers/api"
      end

      if emails_available?
        paths["app/views"] << "lib/views/emails"
        paths["app/mailers"] << "lib/mailers"
      end

      config.to_prepare(&method(:activate).to_proc)
    end
  end
end
