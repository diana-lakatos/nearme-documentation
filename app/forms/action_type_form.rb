# frozen_string_literal: true
class ActionTypeForm < BaseForm
  model 'transactable/action_type'
  property :transactable_type_action_type_id
  property :type
  property :enabled
  property :action_rfq
  property :no_action

  class << self
    def decorate(configuration)
        unless (pricings_configuration = configuration.delete(:pricings)).nil?
          validation = pricings_configuration.delete(:validation)
          validates :pricings, validation if validation.present?
          collection :pricings, form: PricingForm.decorate(pricings_configuration),
                                prepopulator: :pricings_prepopulator,
                                populator: -> (collection:, fragment:, index:, **) {
                                                     item = pricings.find { |pricing| fragment['id'].present? && pricing.id.to_s == fragment['id'].to_s }
                                                     if fragment['_destroy'] == 'true' || check_pricing_attributes(fragment)
                                                       if item
                                                         item.model.mark_for_destruction
                                                         pricings.delete(item)
                                                        end
                                                       return skip!
                                                     end
                                                     item ? item : pricings.append(model.pricings.new)
                                                   }
        end

        configuration.each do |field, options|
          property :"#{field}", options[:property_options].presence || {}
          validates :"#{field}", options[:validation] if options[:validation].present?
        end
      end
  end

  def is_enabled?
    enabled == "true"
  end

  def check_pricing_attributes(fragment)
    !self.enabled || fragment[:enabled] != '1' ||
      check_custom_price_attributes(fragment)
  end

  # we don't want to save custom price without unit or number of units for draft
  # transactables
  def check_custom_price_attributes(fragment)
    fragment[:transactable_type_pricing_id].blank? &&
      (fragment[:unit].blank? || fragment[:number_of_units].blank?)
  end

  def pricings_prepopulator(options)
    all_pricings = []
    model.transactable_type_action_type.pricings.ordered_by_unit.each do |tt_pricing|
      all_pricings << (model.pricings.find { |p| p.transactable_type_pricing_id == tt_pricing.id }.presence || build_pricings(tt_pricing))
    end
    all_pricings << model.pricings.select { |p| p.transactable_type_pricing_id.nil? && p.persisted? }
    all_pricings = all_pricings.flatten.compact.sort { |a, b| [a.unit, a.number_of_units] <=> [b.unit, b.number_of_units] }
    self.pricings = all_pricings + pricings.select { |p| p.transactable_type_pricing_id.nil? && p.new_record? }
  end

  def build_pricings(tt_pricing = nil)
    model.pricings.new(transactable_type_pricing: tt_pricing).tap(:assign_defaults)
  end
end
