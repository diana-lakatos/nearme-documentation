class ReviewDrop < BaseDrop

  attr_reader :review

  # reviewable
  #   polymorphic object
  delegate :reviewable, to: :review

  def initialize(review)
    @review = review.decorate
  end

end
