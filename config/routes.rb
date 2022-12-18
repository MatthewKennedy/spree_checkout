Spree::Core::Engine.add_routes do
  scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do
    # TODO
    # Set this so that a config defines the return cart path, not a route
    # because we want to have the Spree StoreFront still usable, and
    get '/cart', to: 'orders#edit', as: :cart

    namespace :checkout do
      resources :addresses do
        collection do
          get :address_manager
        end
      end

      root                            to: 'orders#edit'
      get   '/:state',                to: 'orders#edit', as: :state

      patch 'update/:state',          to: 'orders#update'
      patch 'apply_coupon',           to: 'orders#apply_coupon',  as: :apply_coupon
      patch 'remove_coupon/:code',    to: 'orders#remove_coupon', as: :remove_coupon
      patch 'update_shipping_choice', to: 'orders#update_shipping_choice'

      post  'change_address_country', to: 'orders#change_address_country'
    end
  end
end
