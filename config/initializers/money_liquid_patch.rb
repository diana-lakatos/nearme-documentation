Money.class_eval do

  def to_liquid
    @money_drop ||= MoneyDrop.new(self)
  end

end