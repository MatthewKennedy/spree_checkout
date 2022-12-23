module Spree
  module StoreDecorator
    def self.prepended(base)
      base.typed_store :spree_checkout_settings, coder: ActiveRecord::TypedStore::IdentityCoder do |s|
        s.boolean :checkout_shipping_instructions, default: true, null: false
        s.boolean :checkout_coupon_codes_enabled, default: true, null: true
        s.boolean :checkout_alternative_shipping_phone, default: false, null: true
        s.boolean :checkout_allow_guest_checkout, default: true, null: true
        s.boolean :checkout_address_requires_phone, default: true, null: true
      end
    end

    ::Spree::Store.prepend self if ::Spree::Store.included_modules.exclude?(self)
  end
end
