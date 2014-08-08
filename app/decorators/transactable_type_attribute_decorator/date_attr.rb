class TransactableTypeAttributeDecorator::DateAttr < TransactableTypeAttributeDecorator::Base

  def options
    {
      as: :date
    }
  end

end
