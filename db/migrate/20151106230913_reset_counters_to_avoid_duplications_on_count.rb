class ResetCountersToAvoidDuplicationsOnCount < ActiveRecord::Migration
  def up
    Instance.where(is_community: true).find_each do |i|
      i.set_context!
      User.find_each do |u|
        User.reset_counters(u.id, :feed_following)
        User.reset_counters(u.id, :feed_followers)
      end
    end
  end

  def down
    # Nothing to do...
  end
end
