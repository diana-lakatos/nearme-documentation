class RequestContextDrop < BaseDrop
  def initialize(request_context)
    @request_context = request_context
  end

  def name
    @request_context.name
  end

  def bookable_noun
    @request_context.bookable_noun
  end

  def bookable_noun_plural
    @request_context.bookable_noun.pluralize
  end
end
