# frozen_string_literal: true
class ActionTypeForm < BaseForm
  model 'transactable/action_type'

  class << self
    def decorate(configuration)
      unless (pricings_configuration = configuration.delete(:pricings)).nil?
        add_property(:pricings, pricings_configuration)
        add_validation(:pricings, pricings_configuration)
        collection :pricings, form: PricingForm.decorate(pricings_configuration),
                              prepopulator: :pricings_prepopulator,
                              populator: ->(collection:, fragment:, index:, **) {
                                           item = pricings.find { |pricing| fragment['id'].present? && pricing.id.to_s == fragment['id'].to_s }
                                           if checked?(fragment['_destroy']) || check_pricing_attributes(fragment)
                                             if item
                                               item.model.mark_for_destruction
                                               pricings.delete(item)
                                              end
                                             return skip!
                                           end
                                           item ? item : pricings.append(model.pricings.new)
                                         }
      end
      inject_dynamic_fields(configuration, whitelisted: [:enabled, :type, :action_rfq, :no_action, :minimum_booking_minutes, :availability_template_id, :transactable_type_action_type_id])
    end
  end

  # @!attribute pricings
  #   @return [Array<PricingForm>] array of pricings for this action type

  # @!attribute availability_template_id
  #   @return [Integer] id of the availability template for the action type
  # @!attribute minimum_booking_minutes
  #   @return [Integer] minimum booking minutes for the action type

  # @!attribute transactable_type_action_type_id
  #   @return [Integer] numeric identifier of the TransactableType::ActionType parent object
  property :transactable_type_action_type_id

  # @!attribute type
  #   @return [String] type of the action type; can be: Transactable::EventBooking,
  #     Transactable::TimeBasedBooking, Transactable::NoActionBooking, Transactable::PurchaseAction,
  #     Transactable::OfferAction, Transactable::SubscriptionBooking
  property :type

  # @!attribute enabled
  #   @return [Boolean] whether the action type is enabled
  property :enabled

  # @!attribute action_rfq
  #   @return [Boolean] whether request for quotation is enabled for the action type (where buyers can send
  #     offers to seller)
  property :action_rfq

  # @!attribute no_action
  #   @return [Boolean] whether the action type is for informative listings (no buttons in booking module)
  property :no_action

  # @return [Boolean] whether the action type is enabled
  def enabled?
    checked?(enabled)
  end

  # @return [Boolean] whether the action type is not enabled or it has a blank
  #   unit or number of units and a blank pricing object
  def check_pricing_attributes(fragment)
    !enabled || !checked?(fragment[:enabled]) || check_custom_price_attributes(fragment)
  end

  # We don't want to save custom price without unit or number of units for draft
  # transactables
  # @return [Boolean] whether the associated pricing is missing and the unit or
  #   number of units is blank
  def check_custom_price_attributes(fragment)
    fragment[:transactable_type_pricing_id].blank? &&
      (fragment[:unit].blank? || fragment[:number_of_units].blank?)
  end

  def pricings_prepopulator(_options)
    return pricings unless pricings.blank?
    all_pricings = []
    model.transactable_type_action_type.pricings.ordered_by_unit.each do |tt_pricing|
      all_pricings << (pricings.find { |p| p.transactable_type_pricing_id.to_i == tt_pricing.id }.presence || build_pricings(tt_pricing))
    end
    all_pricings << pricings.select { |p| p.transactable_type_pricing_id.nil? && p.persisted? }
    all_pricings = all_pricings.flatten.compact.sort { |a, b| [a.unit, a.number_of_units] <=> [b.unit, b.number_of_units] }
    self.pricings = all_pricings + pricings.select { |p| p.transactable_type_pricing_id.nil? && p.new_record? }
  end

  def build_pricings(tt_pricing = nil)
    model.pricings.new(transactable_type_pricing: tt_pricing).tap(:assign_defaults)
  end
end
