class UsersWithUnreadMessagesFinder

  def find
    # We tie each user_message to its thread owner and to its thread recipient
    # We then keep only messages for which the author is different from its tied user (i.e. the tied user is the recipient)
    # We only select users
    # We don't want unread messages for which we've already reminded the user
    # We don't selected deleted user messages or those from different instances from the user
    # We only select messages older than 24 hours
    # We don't want messages with the same owner as the recipient
    # as it confuses our inner join and they should really only be messages sent to self
    User.joins('INNER JOIN user_messages um ON ((um.thread_owner_id = users.id AND um.read_for_owner = false AND um.archived_for_owner = false) OR (um.thread_recipient_id = users.id AND um.read_for_recipient = false AND um.archived_for_recipient = false))')
      .where('um.author_id != users.id')
      .select('distinct users.*')
      .where('um.unread_last_reminded_at is null')
      .where('um.deleted_at is null AND um.instance_id = users.instance_id')
      .where('um.created_at < ?', Time.now - 24.hours)
      .where('um.thread_owner_id != um.thread_recipient_id')
  end

end

