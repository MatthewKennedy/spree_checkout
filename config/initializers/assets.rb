Rails.application.config.assets.precompile << "spree_checkout_manifest.js"

Rails.application.config.assets.configure do |env|
  env.export_concurrent = false
end
