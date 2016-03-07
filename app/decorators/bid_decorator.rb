class BidDecorator < Draper::Decorator

  include FeedbackDecoratorHelper

  delegate_all

  def feedback_object
    object
  end

end
