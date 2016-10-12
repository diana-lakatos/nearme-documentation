class SendActivityEventsSummaryJob < Job
  def perform
    Instance.where(is_community: true).find_each do |instance|
      instance.set_context!

      summary_data = {
        total_events: 0,
        projects: [],
        groups: []
      }

      User.select('notification_preferences.*, users.*').joins(:recurring_notification_preference).find_each do |user|
        #
        # Groups
        #

        if user.group_updates_enabled?
          user.group_collaborated.not_public.each do |group|
            status_update_quantity = ActivityFeedEvent
                                     .with_identifiers("{Group_#{group.id}}")
                                     .where(event: 'user_updated_group_status')
                                     .where('created_at >= ?', 1.week.ago.beginning_of_day).count

            comments_quantity = ActivityFeedEvent
                                .with_identifiers("{Group_#{group.id}}")
                                .where(event: 'user_commented')
                                .where('created_at >= ?', 1.week.ago.beginning_of_day).count

            summary_data[:groups] << {
              name: group.name,
              status_updates: status_update_quantity,
              comments: comments_quantity
            }

            summary_data[:total_events] += status_update_quantity + comments_quantity
          end
        end

        #
        # Transactables
        #

        if user.project_updates_enabled?
          user.transactables.each do |transactable|
            status_update_quantity = ActivityFeedEvent
                                     .with_identifiers("{Transactable_#{transactable.id}}")
                                     .where(event: 'user_updated_transactable_status')
                                     .where('created_at >= ?', 1.week.ago.beginning_of_day).count

            comments_quantity = ActivityFeedEvent
                                .with_identifiers("{Transactable_#{transactable.id}}")
                                .where(event: 'user_commented_on_transactable')
                                .where('created_at >= ?', 1.week.ago.beginning_of_day).count

            summary_data[:projects] << {
              name: transactable.name,
              status_updates: status_update_quantity,
              comments: comments_quantity
            }

            summary_data[:total_events] += status_update_quantity + comments_quantity
          end
        end

        WorkflowStepJob.perform(WorkflowStep::ActivityEventsWorkflow::ActivityEventsSummary, summary_data, user.id)
      end
    end
  end
end
