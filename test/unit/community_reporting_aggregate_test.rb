require 'test_helper'

class CommunityReportingAggregateTest < ActiveSupport::TestCase

  setup do
    @user = create(:user)
  end

  context "oldest reporting period" do
    should "return correct oldest reporting period when activity feed event present" do
      activity_feed_event = FactoryGirl.create(:activity_feed_event)
      created_at = Time.now.utc.weeks_ago(5)
      activity_feed_event.update_column(:created_at, created_at)

      oldest_period = CommunityReportingAggregate.get_oldest_reporting_period
      assert_equal [created_at.at_beginning_of_week, created_at.at_end_of_week], oldest_period
    end

    should "return correct oldest reporting period when activity feed event not present" do
      last_reporting_period = CommunityReportingAggregate.get_last_reporting_period
      oldest_period = CommunityReportingAggregate.get_oldest_reporting_period
      assert_equal last_reporting_period, oldest_period
    end
  end

  context "statistics" do
    should "create correct statistics for users" do
      User.destroy_all

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 0, cre.statistics[:number_of_new_users]

      user1 = FactoryGirl.create(:user)
      user2 = FactoryGirl.create(:user)
      user3 = FactoryGirl.create(:user)
      user1.update_column(:created_at, now.weeks_ago(1))
      user2.update_column(:created_at, now.weeks_ago(10))
      user3.update_column(:created_at, now.weeks_ago(1))

      cre.update_all_statistics
      assert_equal 2, cre.statistics[:number_of_new_users]
    end

    should "create correct statistics for projects" do
      Transactable.destroy_all

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 0, cre.statistics[:number_of_new_projects]

      project1 = FactoryGirl.create(:project)
      project1.update_column(:created_at, now.weeks_ago(1))
      project2 = FactoryGirl.create(:project)
      project2.update_column(:created_at, now.weeks_ago(1))
      project3 = FactoryGirl.create(:project)
      project3.update_column(:created_at, now.weeks_ago(10))

      cre.update_all_statistics
      assert_equal 2, cre.statistics[:number_of_new_projects]
    end

    should "create correct statistics for number of collaborators" do
      Transactable.destroy_all
      TransactableCollaborator.destroy_all

      project1 = FactoryGirl.create(:project)
      project2 = FactoryGirl.create(:project)

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 2, cre.statistics[:projects_with_0_collaborators]
      assert_equal 0, cre.statistics[:projects_with_1_to_5_collaborators]
      assert_equal 0, cre.statistics[:projects_with_6_to_20_collaborators]
      assert_equal 0, cre.statistics[:projects_with_21_or_more_collaborators]

      (1..15).each do |number|
        project_collaborator = TransactableCollaborator.new
        project_collaborator.user = FactoryGirl.create(:user)
        if number <= 10
          project_collaborator.transactable = project1
        else
          project_collaborator.transactable = project2
        end
        project_collaborator.approved_by_owner_at = now
        project_collaborator.approved_by_user_at = now
        project_collaborator.save
        project_collaborator.update_column(:created_at, now.weeks_ago(1))
      end

      cre.update_all_statistics
      assert_equal 0, cre.statistics[:projects_with_0_collaborators]
      assert_equal 1, cre.statistics[:projects_with_1_to_5_collaborators]
      assert_equal 1, cre.statistics[:projects_with_6_to_20_collaborators]
      assert_equal 0, cre.statistics[:projects_with_21_or_more_collaborators]
    end

    should "create correct statistics for number of followers" do
      Transactable.destroy_all
      ActivityFeedSubscription.destroy_all

      project1 = FactoryGirl.create(:project)
      project2 = FactoryGirl.create(:project)

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 2, cre.statistics[:projects_with_0_followers]
      assert_equal 0, cre.statistics[:projects_with_1_to_10_followers]
      assert_equal 0, cre.statistics[:projects_with_11_to_25_followers]
      assert_equal 0, cre.statistics[:projects_with_26_to_100_followers]
      assert_equal 0, cre.statistics[:projects_with_101_to_500_followers]
      assert_equal 0, cre.statistics[:projects_with_501_or_more_followers]

      (1..15).each do |number|
        afs = ActivityFeedSubscription.new
        afs.follower = FactoryGirl.create(:user)
        if number <= 10
          afs.followed = project1
        else
          afs.followed = project2
        end
        afs.save
        afs.update_column(:created_at, now.weeks_ago(1))
      end

      cre.update_all_statistics
      assert_equal 0, cre.statistics[:projects_with_0_followers]
      assert_equal 2, cre.statistics[:projects_with_1_to_10_followers]
      assert_equal 0, cre.statistics[:projects_with_11_to_25_followers]
      assert_equal 0, cre.statistics[:projects_with_26_to_100_followers]
      assert_equal 0, cre.statistics[:projects_with_101_to_500_followers]
      assert_equal 0, cre.statistics[:projects_with_501_or_more_followers]
    end

    should "create correct statistics for number of updates" do
      ActivityFeedEvent.destroy_all

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 0, cre.statistics[:total_number_of_updates]

      afe1 = FactoryGirl.create(:activity_feed_event)
      afe1.update_column(:created_at, now.weeks_ago(1))
      afe2 = FactoryGirl.create(:activity_feed_event)
      afe2.update_column(:created_at, now.weeks_ago(1))

      cre.update_all_statistics
      assert_equal 2, cre.statistics[:total_number_of_updates]
    end

    should "create correct statistics for number of topics" do
      Topic.destroy_all

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 0, cre.statistics[:total_number_of_topics]

      topic1 = FactoryGirl.create(:topic)
      topic1.update_column(:created_at, now.weeks_ago(1))
      topic2 = FactoryGirl.create(:topic)
      topic2.update_column(:created_at, now.weeks_ago(1))

      cre.update_all_statistics
      assert_equal 2, cre.statistics[:total_number_of_topics]
    end

    should "create correct statistics for number of comments" do
      Comment.destroy_all

      now = Time.now.utc

      cre = CommunityReportingAggregate.new
      cre.start_date = now.weeks_ago(1).at_beginning_of_week
      cre.end_date = now.weeks_ago(1).at_end_of_week
      cre.update_all_statistics
      assert_equal 0, cre.statistics[:total_number_of_comments]

      comment1 = FactoryGirl.create(:comment)
      comment1.update_column(:created_at, now.weeks_ago(1))
      comment2 = FactoryGirl.create(:comment)
      comment2.update_column(:created_at, now.weeks_ago(1))

      cre.update_all_statistics
      assert_equal 2, cre.statistics[:total_number_of_comments]
    end
  end

end

