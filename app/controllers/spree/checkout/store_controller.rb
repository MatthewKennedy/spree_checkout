module Spree
  module Checkout
    class StoreController < ApplicationController
      include Spree::Core::ControllerHelpers::Auth
      include Spree::Core::ControllerHelpers::Search
      include Spree::Core::ControllerHelpers::Store
      include Spree::Core::ControllerHelpers::StrongParameters
      include Spree::Core::ControllerHelpers::Locale
      include Spree::Core::ControllerHelpers::Currency
      include Spree::Core::ControllerHelpers::Order
      include Spree::LocaleUrls

      respond_to :html

      helper 'spree/base'
      helper 'spree/locale'
      helper 'spree/currency'

      helper_method :title
      helper_method :title=
      helper_method :accurate_title

      skip_before_action :verify_authenticity_token, only: :ensure_cart, raise: false

      before_action :redirect_to_default_locale

      protected

      # can be used in views as well as controllers.
      # e.g. <% self.title = 'This is a custom title for this view' %>
      attr_writer :title

      def title
        title_string = @title.present? ? @title : accurate_title
        if title_string.present?
          if Spree::Checkout::Config[:always_put_site_name_in_title] && !title_string.include?(default_title)
            [title_string, default_title].join(" #{Spree::Checkout::Config[:title_site_name_separator]} ")
          else
            title_string
          end
        else
          default_title
        end
      end

      def default_title
        current_store.name
      end

      # this is a hook for sub-classes to provide title
      def accurate_title
        current_store.seo_title
      end

      def redirect_unauthorized_access
        if try_spree_current_user
          flash[:error] = Spree.t(:authorization_failure)
          redirect_to spree.forbidden_path
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
