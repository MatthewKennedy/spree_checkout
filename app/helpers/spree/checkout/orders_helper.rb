module Spree
  module Checkout
    module OrdersHelper
      def spree_checkout_available_payment_methods
        @spree_checkout_available_payment_methods ||= @order.available_payment_methods
      end

      def spree_checkout_toaste_class(kind: :notice)
        if kind == :error
          'text-bg-danger'
        else
          'text-bg-dark'
        end
      end

      def spree_checkout_product_images(product, variants)
        if product.variants_and_option_values(current_currency).any?
          variants_without_master_images = variants.reject(&:is_master).map(&:images).flatten

          if variants_without_master_images.any?
            return variants_without_master_images
          end
        end

        variants.map(&:images).flatten
      end

      def spree_checkout_flash_messages(opts = {})
        flashes = ''
        excluded_types = opts[:excluded_types].to_a.map(&:to_s)

        flash.to_h.except('order_completed').each do |msg_type, text|
          next if msg_type.blank? || excluded_types.include?(msg_type)

          flashes << content_tag(:div, class: "alert alert-#{class_for(msg_type)} mb-0") do
            content_tag(:button, '&times;'.html_safe, class: 'close', data: { dismiss: 'alert', hidden: true }) +
              content_tag(:span, text)
          end
        end

        flashes.html_safe
      end

      def spree_checkout_svg_tag(file_name, options = {})
        prefixed_file = "spree/checkout/#{file_name}"

        inline_svg_tag(prefixed_file, options)
      end

      def spree_checkout_logo(image_path = nil, options = {})
        logo_attachment = if defined?(Spree::StoreLogo) && current_store.logo.is_a?(Spree::StoreLogo)
                            current_store.logo.attachment # Spree v5
                          else
                            current_store.logo # Spree 4.x
                          end

        image_path ||= if logo_attachment&.attached? && logo_attachment&.variable?
                         main_app.cdn_image_url(logo_attachment.variant(resize: '244x104>'))
                       elsif logo_attachment&.attached? && logo_attachment&.image?
                         main_app.cdn_image_url(current_store.logo)
                       else
                         asset_path('spree/checkout/spree-logo.svg')
                       end

        path = spree.respond_to?(:checkout_root_path) ? spree.checkout_root_path : main_app.checkout_root_path

        link_to path, 'aria-label': current_store.name, method: options[:method] do
          image_tag image_path, alt: current_store.name, title: current_store.name
        end
      end

      def spree_checkout_express_checkout_payment_methods
        spree_checkout_available_payment_methods.select(&:hosted_checkout?)
      end

      def spree_checkout_next_step_name
        states = @order.checkout_steps
        states.each_with_index.map do |state, _i|
          current_index = states.index(@order.state)
          state_index = states.index(state)

          return state if state_index == current_index + 1
        end
      end

      def spree_checkout_previous_step_name
        states = @order.checkout_steps
        states.each_with_index.map do |state, _i|
          current_index = states.index(@order.state)
          state_index = states.index(state)

          return state if state_index == current_index - 1
        end
      end

      def spree_checkout_checkout_progress_line
        states = @order.checkout_steps
        items = states.each_with_index.map do |state, i|
          text = Spree.t("order_state.#{state}").titleize

          css_classes = []
          current_index = states.index(@order.state)
          state_index = states.index(state)

          css_classes << 'next' if state_index == current_index + 1
          css_classes << 'active' if state == @order.state
          css_classes << 'first' if state_index == 0
          css_classes << 'last' if state_index == states.length - 1

          if state_index < current_index
            css_classes << 'completed'
            text = link_to text, checkout_state_path(state), class: css_classes.join(' ')
          end

          if state_index > current_index
            content_tag('span', text, class: 'cart-progress text-muted')
          else
            content_tag('span', text, class: 'cart-progress')
          end
        end

        content_tag(:div, raw("<span class='cart-progress'><a href='#{spree.cart_path}' class='completed'>#{Spree.t(:cart)}</a></span>" + items.join('')),
                    class: "steps-container text-center step-#{@order.state}", id: 'checkout-steps')
      end
    end
  end
end
