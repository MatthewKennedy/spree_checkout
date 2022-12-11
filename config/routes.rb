Spree::Core::Engine.add_routes do
  scope '(:locale)', locale: /#{Spree.available_locales.join('|')}/, defaults: { locale: nil } do
    patch '/checkout/update/:state', to: 'checkout#update', as: :update_checkout
    get   '/checkout/:state', to: 'checkout#edit', as: :checkout_state
    get   '/checkout', to: 'checkout#edit', as: :checkout
    post  '/checkout/update_country', to: 'checkout#update_country', as: :update_country
  end
end
