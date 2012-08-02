class Rating < ActiveRecord::Base
  attr_accessible :content_id, :user_id, :rating

  belongs_to :user
  belongs_to :content, polymorphic: true

  acts_as_paranoid

  validates :rating, :user_id, :content_id, presence: true
  validates :user_id, uniqueness: { scope: :content_id }
  validates :rating, numericality: { greater_than_or_equal_to: 0.0,
                                     less_than_or_equal_to: 5.0 }

  after_save :update_content_rating_count

  private

  def update_content_rating_count

    # Hack for now. There are better ways of doing this.
    avg = Rating.where(content_id:   self.content_id,
                       content_type: self.content_type).average(:rating)

    count = Rating.where(content_id:   self.content_id,
                         content_type: self.content_type).count(:rating)

    self.content.update_column "rating_average", avg
    self.content.update_column "rating_count", count

  end

end
