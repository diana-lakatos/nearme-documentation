# frozen_string_literal: true
FactoryGirl.define do
  factory :cancel_allowed_cellation_policy, class: CancellationPolicy do
    action_type  "cancel_allowed"
    condition  "{% assign tomorrow = 'now' | date: '%s' | plus: 86400 | times: 1 %}{% assign starts_at = order.starts_at | date: '%s' %}{% assign starts_at_size = starts_at | size %}{% assign difference = starts_at | minus: tomorrow %}{% if starts_at_size != 0 and difference > 0 %}true{% endif %}"
  end

  factory :cancelled_by_host_refund_cellation_policy, class: CancellationPolicy do
    transient do
      penalty_factor 1
    end

    action_type "refund"
    amount_rule { "{{ order.total_amount_money.cents | times: #{penalty_factor} }}" }
    condition "{% if order.state == 'cancelled_by_host' %}true{% endif %}"
  end

  factory :cancelled_by_guest_refund_cellation_policy, class: CancellationPolicy do
    transient do
      penalty_factor 1
    end

    action_type "refund"
    amount_rule { "{{ order.subtotal_amount_money.cents | times: #{penalty_factor} }}" }
    condition "{% if order.state == 'cancelled_by_guest' %}true{% endif %}"
  end
end
