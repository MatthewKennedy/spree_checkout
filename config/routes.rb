Spree::Core::Engine.add_routes do
  scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do

    # TODO Set this so that a config defines the return cart path, not a route
    # because we want to have the Spree StoreFront still usable.
    get '/cart', to: 'orders#edit', as: :cart

    namespace :checkout do
      root to: 'order#edit'

      get   '/:state', to: 'order#edit', as: :state

      patch 'update/:state', to: 'order#update'
      patch 'apply_coupon', to: 'order#apply_coupon'
      patch 'remove_coupon/:code', to: 'order#remove_coupon', as: :remove_coupon
      patch 'update_shipping_choice', to: 'order#update_shipping_choice'

      post  'update_country', to: 'checkout#update_country'
    end
  end
end
