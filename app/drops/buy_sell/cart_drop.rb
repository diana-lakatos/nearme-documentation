class BuySell::CartDrop < BaseDrop
  def initialize(user)
    @user = user
  end

  # orders for this user
  def orders
    @user.cart_orders
  end

  def name
    'WTF'
  end
end
