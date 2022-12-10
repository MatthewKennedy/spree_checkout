module Spree
  module PaymentMethodDecorator
    # Hosted Checkout is a payment method that allows
    # you to bypass all or parts of the standard checkout
    # process.
    #
    # Examples of these are:
    # PayPal Express Checkout, Apple Pay, Google Pay, Amazon Pay
    def hosted_checkout?
      false
    end

    ::Spree::PaymentMethod.prepend self if ::Spree::PaymentMethod.included_modules.exclude?(self)
  end
end
