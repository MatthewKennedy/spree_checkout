require_relative 'lib/spree/checkout/version'

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'spree_checkout'
  s.version     = Spree::Checkout.version
  s.authors     = ['Sean Schofield', 'Spark Solutions']
  s.email       = 'hello@spreecommerce.org'
  s.summary     = 'The default Storefront built with Rails and Turbo/Hotwire for Spree eCommerce platform'
  s.description = s.summary
  s.homepage    = 'https://spreecommerce.org'
  s.license     = 'BSD-3-Clause'

  s.metadata = {
    "bug_tracker_uri"   => "https://github.com/spree/spree/issues",
    "changelog_uri"     => "https://github.com/spree/spree/releases/tag/v#{s.version}",
    "documentation_uri" => "https://dev-docs.spreecommerce.org/",
    "source_code_uri"   => "https://github.com/spree/spree/tree/v#{s.version}",
  }

  s.required_ruby_version = ">= 2.7"

  s.files        = `git ls-files`.split("\n").reject { |f| f.match(/^spec/) && !f.match(/^spec\/fixtures/) }
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'spree_api', ">= #{s.version}"
  s.add_dependency 'spree_core', ">= #{s.version}"

  s.add_dependency 'babel-transpiler'
  s.add_dependency 'canonical-rails'
  s.add_dependency 'inline_svg'
  s.add_dependency 'responders'
  s.add_dependency 'turbo-rails'

  s.add_development_dependency 'capybara-accessible'
end
