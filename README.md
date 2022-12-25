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

If you wish to have Spree Checkout redirect your customer to a different exit point you can add the following to your Spree initializer file.
```ruby
# config/initializers/spree.rb

# Default is : orders creating the path:  /orders/[:order_number]
Rails.configuration.x.spree_checkout.orders_path_name = :your_custom_order_path_name

# Default is :cart crating the path: /cart
Rails.configuration.x.spree_checkout.cart_path_name = :your_custom_cart_path_name
```

## Development

### Helper Methods
To ensure Spree Checkout is a stand-alone Spree extension please scope any helper methods with `spree_checkout_`
don't worry about trying to be DRY any use existing helpers from any other lib, just make a name scoped copy here and
let that take the load, the only requirement for Spree Checkout to run should be Spree Core itself.

### JavaScript
All javascript is found within the `app/javascript` folder.

To work on the Javascript from the root of the `spree_checkout` folder run `yarn install` and then `yarn watch`.

### CSS
All the CSS for Spree Checkout is found within the `app/sass` folder, this is intentionally done
so that Propshaft or Sprockets can pick up ready to use CSS straight out of the assets folder without additional configuration.
This also provides a modern working environment for SCSS processing.

To work on the CSS from the root of the `spree_checkout` folder run `yarn install` and then `yarn watch`.

## TODO

- [ ] Fix address management flow
- [ ] Fix Confirm Order Page
- [ ] Fix logout login flow.
- [ ] Write test suite for checkout flow
