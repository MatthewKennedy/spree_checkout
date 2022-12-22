module Spree
  module Checkout
    class BaseController < ApplicationController
      include Spree::Core::ControllerHelpers::Auth
      include Spree::Core::ControllerHelpers::Search
      include Spree::Core::ControllerHelpers::Store
      include Spree::Core::ControllerHelpers::StrongParameters
      include Spree::Core::ControllerHelpers::Locale
      include Spree::Core::ControllerHelpers::Currency
      include Spree::Core::ControllerHelpers::Order
      include Spree::Checkout::LocaleUrls

      respond_to :html

      helper "spree/base"
      helper "spree/locale"
      helper "spree/currency"

      helper_method :title

      skip_before_action :verify_authenticity_token, only: :ensure_cart, raise: false

      before_action :redirect_to_default_locale

      protected

      default_form_builder(Spree::Checkout::BootstrapBuilder)

      def title
        "#{current_store.name} | #{I18n.t("spree_checkout.secure_checkout")}"
      end

      def redirect_unauthorized_access
        if try_spree_current_user
          flash[:error] = Spree.t(:authorization_failure)
          redirect_to spree.checkout_forbidden_path
        else
          store_location
          if respond_to?(:spree_login_path)
            redirect_to spree_login_path
          else
            redirect_to spree.checkout_root_path
          end
        end
      end
    end
  end
end
