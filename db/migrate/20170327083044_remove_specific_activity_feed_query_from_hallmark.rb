class RemoveSpecificActivityFeedQueryFromHallmark < ActiveRecord::Migration
  def up
    Instances::InstanceFinder.get(:hallmark).each do |i|
      i.set_context!
      i.graph_queries.where(name: 'activity_feed').destroy_all
    end
  end

  def down
  end
end
