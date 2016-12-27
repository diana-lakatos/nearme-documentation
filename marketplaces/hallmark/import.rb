instance = Instance.find(5011)
instance.set_context!

NAME = 0
EMAIL = 1
EXTERNAL_ID = 2
ROLE = 3

def import_hm(path)
  CSV.foreach(path) do |array|
    unless array[NAME] == 'Name'
      email = array[EMAIL].downcase.strip
      puts "importing: #{email}"
      u = User.where('email ilike ?', email).first_or_initialize
      u.email = email
      u.password = SecureRandom.hex(12)
      u.external_id = array[EXTERNAL_ID]
      u.expires_at = Time.zone.now + 6.months
      u.get_default_profile
      u.name = array[NAME]
      u.default_profile.properties[:role] = array[ROLE]&.strip
      u.save!
      if u.metadata['verification_email_sent_at'].blank?
        puts "\tSending email to: #{u.email}"
        WorkflowAlert::InvokerFactory.get_invoker(WorkflowAlert.find(133_65)).invoke!(WorkflowStep::SignUpWorkflow::AccountCreated.new(u.id))
        u.metadata['verification_email_sent_at'] = Time.zone.now
        u.save!
      end
    end
  end
end

import_hm(Rails.root.join('marketplaces', 'hallmark', 'hallmark-community-users.csv'))
#import_hm(Rails.root.join('marketplaces', 'hallmark', 'hallmark-koc.csv'))
