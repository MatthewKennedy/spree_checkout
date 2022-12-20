[![CI](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/ci.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/ci.yml)
[![Standard RB](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardrb.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardrb.yml)
[![Standard JS](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardjs.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/standardjs.yml)
[![StyleLint](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/stylelint.yml/badge.svg)](https://github.com/MatthewKennedy/spree_checkout/actions/workflows/stylelint.yml)

# Spree Checkout

A stand-alone checkout for Spree

## Usage

Spree Checkout can be used with the existing **Spree StoreFront** and **Spree Backend**, either one, or as a stand alone Spree Extension to be used with
any third-party storefront or admin UI.

Additionally, Spree Checkout is both Propshaft and Sprockets ready.


## Installation

Add
```ruby
gem 'spree_checkout'
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
