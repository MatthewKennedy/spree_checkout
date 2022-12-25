module Spree
  module Checkout
    module PathsHelper

      # Provides a localized path to redirect after order completion
      def spree_checkout_completion_route(order)
        path = "#{Rails.application.config_for(:spree_checkout).orders_path_name}/#{order.number}"

        path_localizer(path)
      end

      # Provides a localized path to cart
      def spree_checkout_cart_route(params = {})
        path = Rails.application.config_for(:spree_checkout).cart_path_name

        path_localizer(path)
      end

      private

      def path_localizer(path)
        if current_locale == current_store.default_locale
          "/#{path}"
        else
          "/#{current_locale + path}/"
        end
      end
    end
  end
end
