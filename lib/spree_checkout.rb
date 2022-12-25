require "spree/checkout"

module SpreeCheckout
  class << self
    def configuration
      @configuration ||= Spree::Checkout::Configuration.new
    end

    alias_method :config, :configuration

    def configure
      yield configuration
    end
  end
end
