class FixUsersForUserMessages < ActiveRecord::Migration
  def self.up
    index = 0
    Instance.find_each do |i|
      index += 1
      puts index

      UserMessage.where(instance_id: i.id).each do |um|
        problem_fields = {}

        problem_fields['author']            = User.with_deleted.where(instance_id: i.id).find_by_id(um.author_id)
        problem_fields['thread_owner']      = User.with_deleted.where(instance_id: i.id).find_by_id(um.thread_owner_id)
        problem_fields['thread_recipient']  = User.with_deleted.where(instance_id: i.id).find_by_id(um.thread_recipient_id)

        problem_fields['thread_context'] = false
        if um.thread_context_type == 'User'
          problem_fields['thread_context']  = User.with_deleted.where(instance_id: i.id).find_by_id(um.thread_context_id)
        end

        ['author', 'thread_owner', 'thread_recipient', 'thread_context'].each do |variable|
          if problem_fields[variable].nil?
            user_in_other_instance = User.with_deleted.find_by_id(um["#{variable}_id"])
            correct_user = User.with_deleted.where(instance_id: i.id).find_by_email(user_in_other_instance.email)
            if correct_user
              puts "For #{um.id} to update for #{variable} from " + um.send("#{variable}_id").to_s  + " to " + correct_user.id.to_s
              um.update_column("#{variable}_id", correct_user.id)
            else
              correct_user_any_instance = User.with_deleted.find_by_email(user_in_other_instance.email)
              if !correct_user_any_instance.admin?
                puts "#{um.id}: Unexpected could not find correct user: #{correct_user_any_instance.email} -- not fixed for this message"
              end
            end
          end
        end
      end
    end
  end

  def self.down
    # Not available
  end
end
