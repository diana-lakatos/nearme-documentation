# frozen_string_literal: true
class PopulateCancellationPolicies < ActiveRecord::Migration
  def up
    puts 'Populate Cancellation Policies across instances:'

    if CancellationPolicy.any?
      puts 'Cancelation Policy already set'
      return
    end

    Instance.all.each do |instance|
      instance.set_context!
      puts "- [#{instance.id}] #{instance.name}"

      Order.not_archived.each do |order|
        next unless order.action.instance_of?(Transactable::TimeBasedBooking)
        guest_cancel_refund_factor = order.cancellation_policy_penalty_percentage.zero? ? 1 : order.cancellation_policy_penalty_percentage.to_f / 100
        if Instances::InstanceFinder.get(:ninjunu).include?(instance)
          attributes = [{
            action_type:  'cancellation_penalty',
            amount_rule:  '{% assign tli = order.transactable_line_items | first %}{{ tli.unit_price.cents }}',
            condition:  "{% assign tomorrow = 'now' | parse_time: '%s' | plus: 86400 | times: 1 %}{% assign starts_at = order.starts_at | parse_time: '%s' %}{% assign starts_at_size = starts_at | size %}{% assign difference = starts_at | minus: tomorrow %}{% assign order_states = 'cancelled_by_guest confirmed' | split: ' ' %}{% if order_states contains order.state and starts_at_size != 0 and difference < 0 %}true{% endif %}"
          }]
        else
          attributes = [
            {
              action_type:  'refund',
              amount_rule:  '{{ order.total_amount_money.cents | times: 1 }}',
              condition:  "{% if order.state == 'cancelled_by_host' %}true{% endif %}"
            },
            {
              action_type:  'refund',
              amount_rule:  "{{ order.subtotal_amount_money.cents | times: #{guest_cancel_refund_factor} }}",
              condition:  "{% if order.state == 'cancelled_by_guest' %}true{% endif %}"
            }
          ]

          if order.cancellation_policy_hours_for_cancellation > 0
            attributes << {
              action_type:  'cancel_allowed',
              condition: "{% assign x_hour_as_seconds = 3600 | times: #{order.cancellation_policy_hours_for_cancellation} %}
              {% assign tomorrow = 'now' | parse_time: '%s' | plus: x_hour_as_seconds %}
              {% assign starts_at = order.starts_at | parse_time: '%s' %}
              {% assign starts_at_size = starts_at | size %}
              {% assign difference = starts_at | minus: tomorrow %}
              {% if starts_at_size != 0 and difference < 0 %}true{% endif %}"
            }
          end
        end

        attributes.each do |attrs|
          order.cancellation_policies.create!(attrs)
        end
      end

      TransactableType::TimeBasedBooking.all.each do |tb|
        # Ninjunu
        if Instances::InstanceFinder.get(:ninjunu).include?(instance)
          [{
            action_type:  'cancellation_penalty',
            amount_rule:  '{% assign tli = order.transactable_line_items | first %}{{ tli.unit_price.cents }}',
            condition:  "{% assign tomorrow = 'now' | parse_time: '%s' | plus: 86400 | times: 1 %}{% assign starts_at = order.starts_at | parse_time: '%s' %}{% assign starts_at_size = starts_at | size %}{% assign difference = starts_at | minus: tomorrow %}{% assign order_states = 'cancelled_by_guest confirmed' | split: ' ' %}{% if order_states contains order.state and starts_at_size != 0 and difference < 0 %}true{% endif %}"
          }]
        elsif Instances::InstanceFinder.get(:thevolte).include?(instance)
          [
            {
              action_type:  'cancel_allowed',
              condition:  "{% assign tomorrow = 'now' | parse_time: '%s' | plus: 86400 | times: 1 %}
              {% assign starts_at = order.starts_at | parse_time: '%s' %}
              {% assign starts_at_size = starts_at | size %}
              {% assign difference = starts_at | minus: tomorrow %}
              {% if starts_at_size != 0 and difference > 0 %}true{% endif %}"
            },
            {
              action_type:  'cancel_allowed',
              condition:  "{% assign deliveries_count = order.deliveries | size %}
              {% assign cancellable = true %}
              {% for delivery in order.deliveries %}
                {% if cancellable %}
                  {% assign cancellable = delivery.cancellable? %}
                {% endif %}
              {% endfor %}
              {% if deliveries_count > 0 or cancellable %}true{% endif %}"
            }
          ]
        else
          [
            {
              action_type:  'refund',
              amount_rule:  '{{ order.total_amount_money.cents | times: 1 }}',
              condition:  "{% if order.state == 'cancelled_by_host' %}true{% endif %}"
            },
            {
              action_type:  'refund',
              amount_rule:  '{{ order.subtotal_amount_money.cents | times: 1 }}',
              condition:  "{% if order.state == 'cancelled_by_guest' %}true{% endif %}"
            },
            {
              action_type:  'cancel_allowed',
              amount_rule:  nil,
              condition:  "{% assign starts_at = order.starts_at | parse_time: '%s' %}
              {% assign starts_at_size = starts_at | size %}
              {% assign difference = 'now' | parse_time: '%s' | minus: starts_at %}
              {% if starts_at_size != 0 and difference < 0 %}true{% endif %}"
            }
          ]
        end.each do |attrs|
          tb.cancellation_policies.create!(attrs)
        end
      end
    end
  end

  def down
  end
end
