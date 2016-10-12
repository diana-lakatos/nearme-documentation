class MoneyDrop < BaseDrop
  delegate :currency, :fractional, :amount, :cents, :dollars, :to_money, :to_i, :to_f, to: :source

  def to_s
    @source.amount
  end
end
