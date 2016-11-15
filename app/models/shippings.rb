# frozen_string_literal: true
module Shippings
  class << self
    def table_name_prefix
      'shippings_'
    end

    # TODO: discuss and cover with specs
    # TODO: use Policy pattern?
    def enabled?(subject)
      return unless PlatformContext.current.instance.shipping_providers.any?

      if subject.is_a? Order
        subject.transactables.any? { |transactable| enabled?(transactable) }

      elsif subject.is_a? TransactableType
        subject.action_types.any? { |type| enabled?(type) }

      elsif subject.is_a? Transactable
        enabled?(subject.transactable_type)

      elsif TransactableType::AVAILABLE_ACTION_TYPES.include? subject.class
        shippable_action_type?(subject.class)

      else
        raise 'do not what to with passed attribute'
      end
    end

    def shippable_action_type?(type)
      [
        TransactableType::TimeBasedBooking
      ].include? type
    end

    # TODO: move configuration to file
    def profiles(_type = TransactableType::TimeBasedBooking)
      {
        TransactableType::TimeBasedBooking => %w(one_way return reversed_one_way reversed_return)
      }
    end

    # TODO: move to decorator -> Shippings::Transactable
    def package_list(transactable)
      transactable
        .instance
        .shipping_providers
        .flat_map(&:dimensions_templates)
        .reject(&:entity_id)
        .map { |tpl| [format('%s (%s)', tpl.name, tpl.description), tpl.id] }
    end
  end
end
