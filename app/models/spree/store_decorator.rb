module Spree
  module StoreDecorator
    def self.prepended(base)
      base.typed_store :settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.boolean :checkout_shipping_instructions, default: true, null: false
        s.boolean :checkout_coupon_codes_enabled, default: true, null: true
      end
    end

    ::Spree::Store.prepend self if ::Spree::Store.included_modules.exclude?(self)
  end
end
