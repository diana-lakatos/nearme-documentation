class AddCounterCacheToFollowInteractions < ActiveRecord::Migration
  def change
    remove_column :users, :followers_count, :integer, default: 0, null: false
    remove_column :users, :following_count, :integer, default: 0, null: false

    remove_column :projects, :followers_count, :integer, default: 0, null: false
    remove_column :topics, :followers_count, :integer, default: 0, null: false

    add_counter_cache_for Project, :followers_count, :feed_followers
    add_counter_cache_for Topic, :followers_count, :feed_followers
    add_counter_cache_for User, :followers_count, :feed_followers
    add_counter_cache_for User, :following_count, :feed_followed_users
  end

  def add_counter_cache_for(klass, column_name, count_method)
    add_column klass.table_name.to_sym, column_name, :integer, null: false, default: 0

    klass.reset_column_information

    klass.find_each do |r|
      klass.update_counters r.id, column_name => r.send(count_method).length
    end
  end
end
