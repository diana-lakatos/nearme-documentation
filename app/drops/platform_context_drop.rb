class PlatformContextDrop < BaseDrop
  def initialize(platform_context_decorator)
    @platform_context_decorator = platform_context_decorator
  end

  def name
    @platform_context_decorator.name
  end

  def bookable_noun
    @platform_context_decorator.bookable_noun
  end

  def bookable_noun_plural
    @platform_context_decorator.bookable_noun.pluralize
  end
end
