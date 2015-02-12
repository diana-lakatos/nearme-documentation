class CalculateAverageRating < ActiveRecord::Migration
  def up
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      Review.all.each {|r| r.recalculate_reviewable_average_rating}
    end
  end

  def down
  end
end
