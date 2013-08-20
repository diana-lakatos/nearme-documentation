class Rating < ActiveRecord::Base

  attr_accessible :author_id, :subject_id, :reservation_id, :value, :comment
  after_create :update_cache_for_subject

  belongs_to :author, class_name: 'User', foreign_key: 'author_id'
  belongs_to :subject, class_name: 'User', foreign_key: 'subject_id'
  belongs_to :reservation

  validates :author_id, presence: true
  validates_uniqueness_of :author_id, scope: [:reservation_id],
                          message: "Your rating for this booking has already been submitted."

  validates :reservation_id, presence: true

  validates_presence_of :value, message: "You must vote for thumbs up or thumbs down."
  validates_numericality_of :value, greater_than_or_equal_to: 0, less_than_or_equal_to: 1

  private
  def update_cache_for_subject
    scope = self.class.where(subject_id: subject_id)
    sum = scope.sum(:value)
    count = scope.count
    subject.update_column("#{type.underscore}_count", sum)
    subject.update_column("#{type.underscore}_average", sum.to_f/count.to_f)
  end

end

class GuestRating < Rating
end

class HostRating < Rating
end
