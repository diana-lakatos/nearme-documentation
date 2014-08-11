class TransactableTypeAttributeDecorator::DateTimeAttr < TransactableTypeAttributeDecorator::Base

  def options
    {
      as: :datetime
    }
  end

end
