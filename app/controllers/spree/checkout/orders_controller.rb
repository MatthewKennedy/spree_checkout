module Spree
  module Checkout
    class OrdersController < Spree::Checkout::BaseController
      include Spree::Checkout::AddressBook
      include Spree::Checkout::StateManagment

      before_action :set_cache_header, only: [:edit]
      before_action :set_current_order
      before_action :load_order_with_lock
      before_action :ensure_valid_state_lock_version, only: [:update]
      before_action :set_state_if_present

      before_action :ensure_order_not_completed
      before_action :ensure_checkout_allowed
      before_action :ensure_sufficient_stock_lines
      before_action :ensure_valid_state

      before_action :associate_user
      before_action :check_authorization

      before_action :setup_for_current_state
      before_action :add_store_credit_payments, :remove_store_credit_payments, only: [:update]

      helper 'spree/checkout/orders'

      rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error

      layout 'spree/layouts/spree_checkout'

      def edit; end

      # Updates the order and advances to the next state (when possible.)
      def update
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          @order.temporary_address = !params[:save_user_address]
          unless @order.next
            flash[:error] = @order.errors.full_messages.join("\n")
            redirect_to(spree.checkout_state_path(@order.state)) && return
          end

          if @order.completed?
            @current_order = nil
            flash['order_completed'] = true
            redirect_to completion_route
          else
            redirect_to spree.checkout_state_path(@order.state)
          end
        else
          render :edit, status: :unprocessable_entity
        end
      end

      def update_country
        @order = Spree::Order.new(update_address_country_params)

        # Empty out the zipcode and State on Country change.
        @order.send(params[:address_kind]).zipcode = nil
        @order.send(params[:address_kind]).state = nil

        @address_partial = "#{params[:address_kind]}_state_zip"

        respond_with(@order) do |format|
          format.turbo_stream
        end
      end

      def apply_coupon
        current_order.coupon_code = params[:order][:coupon_code]
        @result = coupon_handler.new(current_order).apply

        @order.update_with_updater!

        respond_with(@order) do |format|
          format.turbo_stream { render :update_summary }
        end
      end

      def remove_coupon
        current_order.coupon_code = params[:code]
        @result = coupon_handler.new(current_order).remove(params[:code])

        @order.update_with_updater!

        respond_with(@order) do |format|
          format.turbo_stream { render :update_summary }
        end
      end

      def update_shipping_choice
        if @order.update_from_params(params, permitted_checkout_attributes, request.headers.env)
          @order.update_with_updater!

          respond_with(@order) do |format|
            format.turbo_stream { render :update_summary }
          end
        else
          render :edit, status: :unprocessable_entity
        end
      end

      private

      def update_address_country_params
        params.fetch(:order, {}).permit(permitted_order_attributes)
      end

      def ensure_checkout_allowed
        redirect_to spree.cart_path unless @order.checkout_allowed?
      end

      def ensure_order_not_completed
        redirect_to spree.cart_path if @order.completed?
      end

      def ensure_sufficient_stock_lines
        if @order.insufficient_stock_lines.present?
          flash[:error] = Spree.t(:inventory_error_flash_for_insufficient_quantity)
          redirect_to spree.cart_path
        end
      end

      def add_store_credit_payments
        if params.key?(:apply_store_credit)
          add_store_credit_service.call(order: @order)

          # Remove other payment method parameters.
          params[:order].delete(:payments_attributes)
          params[:order].delete(:existing_card)
          params.delete(:payment_source)

          # Return to the Payments page if additional payment is needed.
          redirect_to spree.checkout_state_path(@order.state) and return if @order.payments.valid.sum(:amount) < @order.total
        end
      end

      def remove_store_credit_payments
        if params.key?(:remove_store_credit)
          remove_store_credit_service.call(order: @order)
          redirect_to spree.checkout_state_path(@order.state) and return
        end
      end

      def rescue_from_spree_gateway_error(exception)
        flash.now[:error] = Spree.t(:spree_gateway_error_flash_for_checkout)
        @order.errors.add(:base, exception.message)
        render :edit, status: :unprocessable_entity
      end

      def check_authorization
        authorize!(:edit, current_order, cookies.signed[:token])
      end

      def set_cache_header
        response.headers['Cache-Control'] = 'no-store'
      end

      def add_store_credit_service
        Spree::Dependencies.checkout_add_store_credit_service.constantize
      end

      def remove_store_credit_service
        Spree::Dependencies.checkout_remove_store_credit_service.constantize
      end

      def coupon_handler
        Spree::PromotionHandler::Coupon
      end
    end
  end
end
