class ReviewDrop < BaseDrop

  # @return [ReviewDrop]
  attr_reader :review

  # @!method reviewable
  #   @return [Object] polymorphic object (can be of multiple types)
  delegate :reviewable, to: :review

  def initialize(review)
    @review = review.decorate
  end

end
