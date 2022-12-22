class AddSpreeCheckoutSettingsToSpreeStores < ActiveRecord::Migration[7.0]
  def change
    change_table :spree_stores do |t|
      if t.respond_to? :jsonb
        add_column :spree_stores, :spree_checkout_settings, :jsonb
      else
        add_column :spree_stores, :spree_checkout_settings, :json
      end
    end
  end
end
