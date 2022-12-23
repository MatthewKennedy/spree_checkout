module Spree
  module Checkout
    module BaseHelper
      def spree_checkout_toaste_class(kind: :notice)
        if kind == :error
          "text-bg-danger"
        else
          "text-bg-dark"
        end
      end

      def spree_checkout_accordion_show_hide(index)
        if index == 0
          "show"
        else
          ""
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

      def spree_checkout_express_checkout_payment_methods
        spree_checkout_available_payment_methods.select(&:hosted_checkout?)
      end

      def spree_checkout_flash_messages(opts = {})
        return unless flash.present?

        render "spree/checkout/shared/toast", message: flash.first[1], kind: flash.first[0]
      end

      def spree_checkout_logo(image_path = nil, options = {})
        logo_attachment = if defined?(Spree::StoreLogo) && current_store.logo.is_a?(Spree::StoreLogo)
          current_store.logo.attachment # Spree v5
        else
          current_store.logo # Spree 4.x
        end

        image_path ||= if logo_attachment&.attached? && logo_attachment&.variable?
          main_app.cdn_image_url(logo_attachment.variant(resize: "244x104>"))
        elsif logo_attachment&.attached? && logo_attachment&.image?
          main_app.cdn_image_url(current_store.logo)
        else
          asset_path("spree/checkout/spree-logo.svg")
        end

        path = spree.respond_to?(:checkout_root_path) ? spree.checkout_root_path : main_app.checkout_root_path

        link_to path, "aria-label": current_store.name, method: options[:method] do
          image_tag image_path, alt: current_store.name, title: current_store.name
        end
      end

      def spree_checkout_svg_tag(file_name, options = {})
        prefixed_file = "spree/checkout/#{file_name}"

        inline_svg_tag(prefixed_file, options)
      end

      def spree_checkout_checkout_progress_line
        states = @order.checkout_steps
        items = states.each_with_index.map do |state, i|
          text = Spree.t("order_state.#{state}").titleize

          css_classes = []
          current_index = states.index(@order.state)
          state_index = states.index(state)

          css_classes << "next" if state_index == current_index + 1
          css_classes << "active" if state == @order.state
          css_classes << "first" if state_index == 0
          css_classes << "last" if state_index == states.length - 1

          if state_index < current_index
            css_classes << "completed"
            text = link_to text, checkout_state_path(state), class: css_classes.join(" ")
          end

          if state_index > current_index
            content_tag("span", text, class: "cart-progress text-muted")
          else
            content_tag("span", text, class: "cart-progress")
          end
        end

        content_tag(:div, raw("<span class='cart-progress'><a href='#{spree.cart_path}' class='completed'>#{Spree.t(:cart)}</a></span>" + items.join("")),
          class: "steps-container text-center step-#{@order.state}", id: "checkout-steps")
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

      def spree_checkout_menu(location = 'checkout_footer')
        method_name = "for_#{location}"

        if available_menus.respond_to?(method_name) && Spree::Menu::MENU_LOCATIONS_PARAMETERIZED.include?(location)
          available_menus.send(method_name, I18n.locale) || current_store.default_menu(location)
        end
      end

      def spree_checkout_spree_nav_link_tag(item, opts = {}, &block)
        if item.new_window
          target = opts[:target] || "_blank"
          rel = opts[:rel] || "noopener noreferrer"
        end

        active_class = if request && current_page?(spree_checkout_spree_localized_link(item))
          "active #{opts[:class]}"
        else
          opts[:class]
        end

        link_opts = {target: target, rel: rel, class: active_class, id: opts[:id], data: opts[:data], aria: opts[:aria]}

        if block
          link_to spree_checkout_spree_localized_link(item), link_opts, &block
        else
          link_to item.name, spree_checkout_spree_localized_link(item), link_opts
        end
      end

      private

      def spree_checkout_spree_localized_link(item)
        return if item.link.nil?

        output_locale = if locale_param
          "/#{I18n.locale}"
        end

        if ["Spree::CmsPage"].include?(item.linked_resource_type)
          output_locale.to_s + "checkout" + item.link
        else
          item.link
        end
      end
    end
  end
end
