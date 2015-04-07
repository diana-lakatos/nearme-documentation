desc "wrong user stats"
task wrong_user_stats: :environment do
  WrongUserStats.new.process
end

class WrongUserStats
  def initialize
    @wrong = {}
  end

  def process
    includes = [
      {company_users: :company}, :created_companies, :instance_admins, :authentications,
      :tickets, :ticket_message_attachments, :authored_messages, :reservations
    ]
    User.not_admin.includes(includes).find_each do |u|
      process_association(u, :created_companies)
      process_association(u, :companies) do |c|
        process_company_association(u, c, :locations)
        process_company_association(u, c, :listings)
      end
      process_association(u, :instance_admins)
      process_association(u, :tickets)
      process_association(u, :ticket_message_attachments)
      process_association(u, :authored_messages)
      process_association(u, :reservations)
      process_association(u, :authentications)
    end

    @wrong.each do |entity, num|
      puts "wrong #{entity} num: #{num}"
    end
  end

  private

  def process_association(user, assoc)
    @wrong[assoc] ||= 0
    user.send(assoc).each do |entity|
      @wrong[assoc] += 1 unless entity.instance_id == user.instance_id
      yield(entity) if block_given?
    end
  end

  def process_company_association(user, company, assoc)
    @wrong[assoc] ||= 0
    company.send(assoc).each do |entity|
      @wrong[assoc] += 1 if user.instance_id != entity.instance_id || company.creator_id != entity.creator_id
    end
  end
end
