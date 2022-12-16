module Spree
  # This is somewhat contrary to standard REST convention since there is not
  # actually a Checkout object. There's enough distinct logic specific to
  # checkout which has nothing to do with updating an order that this approach
  # is warranted.
  class CheckoutController < Spree::StoreController
    include Spree::Checkout::AddressBook

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

    helper 'spree/orders'

    rescue_from Spree::Core::GatewayError, with: :rescue_from_spree_gateway_error

    layout 'spree/layouts/checkout'

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
      @order = Spree::Order.new(update_country_params)

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

    def unknown_state?
      (params[:state] && !@order.has_checkout_step?(params[:state])) ||
        (!params[:state] && !@order.has_checkout_step?(@order.state))
    end

    def insufficient_payment?
      params[:state] == 'confirm' &&
        @order.payment_required? &&
        @order.payments.valid.sum(:amount) != @order.total
    end

    def correct_state
      if unknown_state?
        @order.checkout_steps.first
      elsif insufficient_payment?
        'payment'
      else
        @order.state
      end
    end

    def ensure_valid_state
      if @order.state != correct_state && !skip_state_validation?
        flash.keep
        @order.update_column(:state, correct_state)
        redirect_to spree.checkout_state_path(@order.state)
      end
    end

    # Should be overridden if you have areas of your checkout that don't match
    # up to a step within checkout_steps, such as a registration step
    def skip_state_validation?
      false
    end

    def load_order_with_lock
      @order = current_order(lock: true)
      redirect_to(spree.cart_path) && return unless @order
    end

    def ensure_valid_state_lock_version
      if params[:order] && params[:order][:state_lock_version]
        changes = @order.changes if @order.changed?
        @order.reload.with_lock do
          unless @order.state_lock_version == params[:order].delete(:state_lock_version).to_i
            flash[:error] = Spree.t(:order_already_updated)
            redirect_to(checkout_state_path(@order.state)) && return
          end
          @order.increment!(:state_lock_version)
        end
        @order.assign_attributes(changes) if changes
      end
    end

    def set_state_if_present
      if params[:state]
        redirect_to spree.checkout_state_path(@order.state) if @order.can_go_to_state?(params[:state]) && !skip_state_validation?
        @order.state = params[:state]
      end
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

    # Provides a route to redirect after order completion
    def completion_route(custom_params = {})
      spree.order_path(@order, custom_params.merge(locale: locale_param))
    end

    def setup_for_current_state
      method_name = :"before_#{@order.state}"
      send(method_name) if respond_to?(method_name, true)
    end

    def before_address
      # if the user has a default address, a callback takes care of setting
      # that; but if he doesn't, we need to build an empty one here
      @order.bill_address ||= Address.new(country: current_store.default_country, user: try_spree_current_user)
      if @order.checkout_steps.include?('delivery')
        @order.ship_address ||= Address.new(country: current_store.default_country,
                                            user: try_spree_current_user)
      end

      @bill_address ||= @order.bill_address
      @ship_address ||= @order.ship_address
    end

    def before_delivery
      return if params[:order].present?

      packages = @order.shipments.map(&:to_package)
      @differentiator = Spree::Stock::Differentiator.new(@order, packages)
    end

    def before_payment
      if @order.checkout_steps.include? 'delivery'
        packages = @order.shipments.map(&:to_package)
        @differentiator = Spree::Stock::Differentiator.new(@order, packages)
        @differentiator.missing.each do |variant, quantity|
          Spree::Dependencies.cart_remove_item_service.constantize.call(order: @order, variant: variant, quantity: quantity)
        end
      end

      return unless try_spree_current_user.respond_to?(:payment_sources)

      @payment_sources = try_spree_current_user.payment_sources.where(payment_method: @order.available_payment_methods)
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

    def update_country_params
      params.fetch(:order, {}).permit(permitted_order_attributes)
    end

    def coupon_handler
      Spree::PromotionHandler::Coupon
    end
  end
end
