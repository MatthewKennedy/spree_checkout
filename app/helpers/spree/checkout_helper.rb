module Spree
  module CheckoutHelper
    def spree_checkout_svg_tag(file_name, options = {})
      prefixed_file = "spree/checkout/#{file_name}"

      inline_svg_tag(prefixed_file, options)
    end

    def express_checkout_payment_methods
      checkout_available_payment_methods.select(&:hosted_checkout?)
    end

    def compact_promotion(order)
      promo_ids = []
      promotion_info = nil

      order.line_item_adjustments.promotion.eligible.group_by(&:source_id).each do |source_id, _adjustment|
        promo_ids << source_id
      end

      promo_ids.each do |promo_id|
        promotion_info = promotion_info(order, promo_id)
      end

      promotion_info
    end

    def promotion_info(order, promo_id)
      data = {}
      label = []
      code = []
      name = []
      amt = []

      order.line_item_adjustments.promotion.eligible.each do |adjustment|
        next unless adjustment.source_id.to_s == promo_id.to_s

        code << if adjustment.source.promotion.code.present?
                  adjustment.source.promotion.code
                end
        name << adjustment.source.promotion.name
        label << adjustment.label
        amt << adjustment.amount
      end

      total = amt.sum
      display_total = Spree::Money.new(total, currency: order.currency)

      data[:label] = label.first
      data[:code] = code.first
      data[:name] = name.first
      data[:total] = display_total.to_s

      data
    end

    def next_step_name
      states = @order.checkout_steps
      states.each_with_index.map do |state, _i|
        current_index = states.index(@order.state)
        state_index = states.index(state)

        return state if state_index == current_index + 1
      end
    end

    def previous_step_name
      states = @order.checkout_steps
      states.each_with_index.map do |state, _i|
        current_index = states.index(@order.state)
        state_index = states.index(state)

        return state if state_index == current_index - 1
      end
    end

    def checkout_progress_line(numbers: false)
      states = @order.checkout_steps
      items = states.each_with_index.map do |state, i|
        text = Spree.t("order_state.#{state}").titleize
        text.prepend("#{i.succ}. ") if numbers

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
