class CommunityReportingAggregate < ActiveRecord::Base

  auto_set_platform_context
  scoped_to_platform_context

  COLUMNS = {
    number_of_new_users: '# of New Users',
    number_of_new_projects: '# of New Projects',
    projects_with_0_collaborators: 'Projects with 0 Collaborators',
    projects_with_1_to_5_collaborators: 'Projects with 1 to 5 Collaborators',
    projects_with_6_to_20_collaborators: 'Projects with 6 to 20 Collaborators',
    projects_with_21_or_more_collaborators: 'Projects with 21 or more Collaborators',
    projects_with_0_followers: 'Projects with 0 Followers',
    projects_with_1_to_10_followers: 'Projects with 1 to 10 Followers',
    projects_with_11_to_25_followers: 'Projects with 11 to 25 Followers',
    projects_with_26_to_100_followers: 'Projects with 26 to 100 Followers',
    projects_with_101_to_500_followers: 'Projects with 101 to 500 Followers',
    projects_with_501_or_more_followers: 'Projects with 501 or more Followers',
    total_number_of_updates: 'Total Number of Updates',
    total_number_of_topics: 'Total Number of Topics',
    total_number_of_comments: 'Total Number of Comments',
  }

  def self.get_last_reporting_period
    week_ago = Time.now.utc - 1.week
    [week_ago.at_beginning_of_week, week_ago.at_end_of_week]
  end

  def self.get_oldest_reporting_period
    oldest_event = ActivityFeedEvent.order('created_at ASC').first
    if oldest_event
      created_time = oldest_event.created_at.utc
      [created_time.at_beginning_of_week, created_time.at_end_of_week]
    else
      CommunityReportingAggregate.get_last_reporting_period
    end
  end

  def get_next_reporting_period
    day_in_next_week = self.end_date + 1.day
    [day_in_next_week.at_beginning_of_week, day_in_next_week.at_end_of_week]
  end

  def update_all_statistics
    update_number_of_new_users
    update_number_of_new_projects
    update_number_of_projects_by_collaborators_range(0, 0)
    update_number_of_projects_by_collaborators_range(1, 5)
    update_number_of_projects_by_collaborators_range(6, 20)
    update_number_of_projects_by_collaborators_range(21, nil)

    update_number_of_projects_by_followers_range(0, 0)
    update_number_of_projects_by_followers_range(1, 10)
    update_number_of_projects_by_followers_range(11, 25)
    update_number_of_projects_by_followers_range(26, 100)
    update_number_of_projects_by_followers_range(101, 500)
    update_number_of_projects_by_followers_range(501, nil)
    update_total_number_of_updates
    update_total_number_of_topics
    update_total_number_of_comments
  end

  def get_values_for_record
    [start_date.strftime('%Y-%m-%d'), end_date.strftime('%Y-%m-%d')] + COLUMNS.keys.collect do |key|
      statistics[key.to_s]
    end
  end

  protected

  def update_number_of_new_users
    statistics[:number_of_new_users] = User.where('created_at >= ? AND created_at < ?', start_date, end_date).count
  end

  def update_number_of_new_projects
    statistics[:number_of_new_projects] = Project.where('created_at >= ? AND created_at < ?', start_date, end_date).count
  end

  def update_number_of_projects_by_collaborators_range(from_collaborators, to_collaborators)
    if to_collaborators.present? && to_collaborators.zero?
      statistics[:projects_with_0_collaborators] = Project.joins('left join project_collaborators pc ON pc.project_id = projects.id').where('pc.id is null').group('projects.id').count.length
    else
      if to_collaborators.blank?
        to_collaborators = 2 ** 32
        hash_key = "projects_with_#{from_collaborators}_or_more_collaborators"
      else
        hash_key = "projects_with_#{from_collaborators}_to_#{to_collaborators}_collaborators"
      end

      statistics[hash_key.to_sym] = Project.joins('left join project_collaborators pc ON pc.project_id = projects.id').where('pc.created_at >= ? AND pc.created_at < ?', start_date, end_date).group('projects.id').having('count(projects.id) >= ? AND count(projects.id) < ?', from_collaborators, to_collaborators).count.length
    end
  end

  def update_number_of_projects_by_followers_range(from_followers, to_followers)
    if to_followers.present? && to_followers.zero?
      statistics[:projects_with_0_followers] = Project.joins("left join activity_feed_subscriptions afs ON afs.followed_id = projects.id AND afs.followed_type = 'Project'").where('afs.id is null').group('projects.id').count.length
    else
      if to_followers.blank?
        to_followers = 2 ** 32
        hash_key = "projects_with_#{from_followers}_or_more_followers"
      else
        hash_key = "projects_with_#{from_followers}_to_#{to_followers}_followers"
      end

      statistics[hash_key.to_sym] = Project.joins("left join activity_feed_subscriptions afs ON afs.followed_id = projects.id AND afs.followed_type = 'Project'").where('afs.created_at >= ? AND afs.created_at < ?', start_date, end_date).group('projects.id').having('count(projects.id) >= ? AND count(projects.id) < ?', from_followers, to_followers).count.length
    end
  end

  def update_total_number_of_updates
    statistics["total_number_of_updates"] = ActivityFeedEvent.where('created_at >= ? AND created_at < ?', start_date, end_date).count
  end

  def update_total_number_of_topics
    statistics["total_number_of_topics"] = Topic.where('created_at >= ? AND created_at < ?', start_date, end_date).count
  end

  def update_total_number_of_comments
    statistics["total_number_of_comments"] = Comment.where('created_at >= ? AND created_at < ?', start_date, end_date).count
  end

end

