class InstanceDrop < Liquid::Drop
  def initialize(instance)
    @instance = instance
  end

  def bookable_noun
    @instance.bookable_noun
  end

  def bookable_noun_plural
    @instance.bookable_noun.pluralize
  end
end
