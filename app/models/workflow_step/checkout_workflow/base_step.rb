# frozen_string_literal: true
class WorkflowStep::CheckoutWorkflow::BaseStep < WorkflowStep::BaseStep
  def initialize(shopping_cart_id)
    @shopping_cart = ShoppingCart.find_by(id: shopping_cart_id)
    @user = @shopping_cart&.user
  end

  def workflow_type
    'checkout'
  end

  def data
    {
      shopping_cart: @shopping_cart,
      user: @user
    }
  end

  def enquirer
    @user
  end

  def lister
    @user
  end

  def should_be_processed?
    @shopping_cart.present? && @user.present?
  end
end
