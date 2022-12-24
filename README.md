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
# TEMP TESTING SPREE FRONTEND - RECOMMENDED AT THIS STAGE
gem 'spree_frontend', github: 'spree/spree_legacy_frontend', branch: 'feature/use-spree-checkout'
gem 'spree_checkout', github: 'MatthewKennedy/spree_checkout'

# AUTH DEVISE COMPATIBLE VERSION
gem 'spree_auth_devise', github: 'spree/spree_auth_devise', branch: 'feature/prep-for-stand-alone-checkout'
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


## Checkout Flow

For the most part, the checkout flow is unchanged, your customer enters the checkout at `/checkout`
and upon completion the user is forwarded to `/orders/:order_number`, so this should be a drop-in replacement for
your existing checkout system.

When used with `spree_auth_devise` your customer is sent to the registrations page as the first checkout step by default.
This can be changed so the customer is sent to the Address page as the first step be setting the following config:

```ruby
# config/initializers/spree.rb

Rails.application.config.after_initialize do
  Spree::Auth::Config[:registration_step] = false
end
```

## TODO

- [ ] Fix address management flow
- [ ] Fix Confirm Order Page
- [ ] Fix logout login flow.
- [ ] Write test suite for checkout flow
