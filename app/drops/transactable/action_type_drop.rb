class Transactable::ActionTypeDrop < BaseDrop
  attr_reader :action_type

  delegate :id, :pricings, to: :action_type

  def initialize(action_type)
    @action_type = action_type
  end

  def first_pricing
    pricings.first
  end

  def sorted_pricings
    pricings.sort_by(&:number_of_units)
  end
end
