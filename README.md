[![CI](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/ci.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/ci.yml)
[![Standard RB](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardrb.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardrb.yml)
[![Standard JS](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardjs.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardjs.yml)
[![StyleLint](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/stylelint.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/stylelint.yml)

# Spree Checkout

A stand-alone checkout for Spree

## Usage

Spree Checkout can be used with the existing **Spree StoreFront** and **Spree Backend**, either one, or as a stand-alone Spree Extension to be used with
any third-party storefront or admin UI.

Additionally, Spree Checkout is both Propshaft and Sprockets ready.


## Installation

Add
```ruby
# TEMP TESTING SPREE FRONTEND
gem 'spree_frontend', github: 'spree/spree_legacy_frontend', branch: 'feature/use-spree-checkout'

# TEMP FOR AUTH DEVISE
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: 'feature/prep-for-stand-alone-checkout'

gem 'spree_checkout', github: 'MatthewKennedy/spree_checkout'
```
to your `Gemfile`.

Run:

```bash
bundle install
bin/rails g spree:checkout:install
```

### Using Propshaft

You're good to go.

### Using Sprockets

Add for following to your app/assets/config/manifest.js
```js
//= link spree/checkout/spree_checkout.min.css
//= link spree_checkout.min.js
//= link spree/checkout/spree-logo.svg
```
then restart your server.


## TODO

- [ ] Fix address management flow
- [ ] Fix Confirm Order Page
- [ ] Fix logout login flow.
- [ ] Write test suite for checkout flow

### Questions
When a user signs out on the checkout/address page, should we send them back to the store,
or build them a new order and land them back at the address page or registration page keeping them
in the checkout flow?

How do we handle the flexibility of using this with or without the standard Rails frontend vs API.
For example if the buyer completes an order, do we send them to `orders/R123456799` and let the frontend
take it from there, or do we try to handle that withing the scope of the `spree_checkout` application?




