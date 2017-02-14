instance = Instance.find(5011)
instance.set_context!

EXTERNAL_ID = 0
FIRST_NAME = 1
LAST_NAME = 2
EMAIL = 3
DOB = 4
PHONE = 5
MEMBER_SINCE = 6
EXPIRES_AT = 7
MEMBER_YEAR = 8

def import_hm(path)
  CSV.foreach(path, col_sep: '|') do |array|
    unless array[FIRST_NAME] == 'CNSMR_FIRST_NM'
      email = array[EMAIL].downcase.strip
      if email.include?('@')
        emails << email
        puts "importing: #{email}"
        u = User.where('email ilike ?', email).first_or_initialize
        u.email = email
        u.password = SecureRandom.hex(12) unless u.encrypted_password.present?
        u.external_id = array[EXTERNAL_ID]
        u.expires_at = Date.strptime(array[EXPIRES_AT], '%Y%m').end_of_month
        u.get_default_profile
        u.properties.date_of_birth = begin
                                       Date.strptime(array[DOB], '%m%d%Y')
                                     rescue
                                       puts "\tInvalid DOB: #{array[DOB]}"
                                       nil
                                     end
        u.properties.member_since = begin
                                      Date.strptime(array[MEMBER_SINCE], '%Y%m')
                                    rescue
                                      puts "\tInvalid MEMBER_SINCE: #{array[MEMBER_SINCE]}"
                                      nil
                                    end
        u.properties.member_year = array[MEMBER_YEAR]
        u.mobile_number = array[PHONE]
        u.first_name = array[FIRST_NAME].humanize
        u.last_name = array[LAST_NAME].humanize
        u.verified_at = Time.zone.now
        u.save!
        if u.metadata['verification_email_sent_at'].blank?
          puts "\tSending email to: #{u.email}"
          WorkflowAlert::InvokerFactory.get_invoker(WorkflowAlert.find(133_65)).invoke!(WorkflowStep::SignUpWorkflow::AccountCreated.new(u.id))
          u.metadata['verification_email_sent_at'] = Time.zone.now
          u.save!
        end
      else
        puts "Skipping due to email: #{email}"
      end
    end
  end
  puts "Imported in total: #{email.count} users"
end

import_hm(Rails.root.join('marketplaces', 'hallmark', 'KOC_Data_07Feb.txt'))
#import_hm(Rails.root.join('marketplaces', 'hallmark', 'hallmark-community-users.csv'))
#import_hm(Rails.root.join('marketplaces', 'hallmark', 'hallmark-koc.csv'))
