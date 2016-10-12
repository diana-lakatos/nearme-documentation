class RatingHint < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context
  has_paper_trail
  acts_as_paranoid

  belongs_to :rating_system
  belongs_to :instance

  default_scope { order('value DESC') }

  def description_or_value
    description.presence || value
  end
end
