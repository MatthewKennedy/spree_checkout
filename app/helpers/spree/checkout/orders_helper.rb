module Spree
  module Checkout
    module OrdersHelper
      def spree_checkout_available_payment_methods
        @spree_checkout_available_payment_methods ||= @order.available_payment_methods
      end
    end
  end
end
