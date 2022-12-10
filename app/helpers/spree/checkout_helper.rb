module Spree
  module CheckoutHelper
    def spree_checkout_svg_tag(file_name, options = {})
      prefixed_file = "spree/checkout/#{file_name}"

      inline_svg_tag(prefixed_file, options)
    end

    def express_checkout_payment_methods
      checkout_available_payment_methods.select(&:hosted_checkout?)
    end

    def checkout_progress_line(numbers: false)
      states = @order.checkout_steps
      items = states.each_with_index.map do |state, i|
        text = Spree.t("order_state.#{state}").titleize
        text.prepend("#{i.succ}. ") if numbers

        css_classes = []
        current_index = states.index(@order.state)
        state_index = states.index(state)

        if state_index < current_index
          css_classes << 'completed'
          text = link_to text, checkout_state_path(state)
        end

        css_classes << 'next' if state_index == current_index + 1
        css_classes << 'active' if state == @order.state
        css_classes << 'first' if state_index == 0
        css_classes << 'last' if state_index == states.length - 1

        if state_index < current_index
          content_tag('span', text, class: css_classes.join(' '))
        else
          content_tag('span', content_tag('a', text, class: css_classes.join(' ')), class: 'cart-progress')
        end
      end
      content_tag(:div,
                  raw("<span class='cart-progress'><a href='#{spree.cart_path}' class='completed'>#{Spree.t(:cart)}</a></span>" + items.join),
                  class: "steps-container text-center step-#{@order.state}", id: 'checkout-steps')
    end
  end
end
