class ActionTypeDrop < BaseDrop

  attr_reader :action_type

  delegate :id, :pricings, to: :action_type

  def initialize(action_type)
    @action_type = action_type
  end

end
