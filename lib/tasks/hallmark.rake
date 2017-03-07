namespace :hallmark do
  desc 'Setup hallmark'

  task groups: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    %w(Public Moderated Private Secret).each do |name|
      group_type = GroupType.where(name: name).first_or_create!

      group_type.custom_validators.where(field_name: 'name').first_or_initialize.tap do |cv|
        cv.max_length = 140
      end.save!

      group_type.custom_validators.where(field_name: 'description').first_or_initialize.tap do |cv|
        cv.max_length = 5000
      end.save!

      group_type.custom_attributes.where(name: 'videos').first_or_initialize.tap do |ca|
        ca.public = true
        ca.html_tag = 'input'
        ca.attribute_type = 'array'
        ca.label = 'Videos'
        ca.hint = 'Enter URL to Youtube or Vimeo video'
        ca.public = true
        ca.searchable = false
      end.save!
    end
  end

  task setup: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!

    WorkflowAlert
      .find_by(instance_id: instance.id, name: 'Member approved email')
      .try(:update_columns,         name: 'Notify user of approved join request',
    template_path: 'group_mailer/notify_user_of_approved_join_request')

    Workflow.find_by(instance_id: instance.id, workflow_type: 'group_workflow').workflow_steps.each do |step|
      step.workflow_alerts.where(alert_type: 'email').each do |alert|
        alert.update!(
          from: 'from@hallmark.com',
          reply_to: 'replyto@hallmark.com'
        )
      end
    end

    Rails.cache.clear
  end

  task import_users: [:environment] do
    instance = Instance.find(5011)
    instance.set_context!
    path = Rails.root.join('marketplaces', 'hallmark', 'users-hallmark.csv')
    mapping = {
      external_id: 0,
      first_name: 1,
      last_name: 2,
      email: 3,
      date_of_birth: 4,
      phone: 5,
      created_at: 6,
      member_since: 7,
      expires_at: 8,
      member_year: 9
    }
    index = 0
    puts "Importing..."
    imported_users = Set.new
    errors = {}
    good_records = []
    CSV.foreach(path) do |array|
      index += 1
      errors[index] = []
      if(index % 200).zero?
        puts "\t\tImported #{index} users"
      end
      if array[mapping.fetch(:email)].blank?
        errors[index] << "Blank email"
      end
      external_id = array[mapping.fetch(:external_id)].strip
      if imported_users.include?(external_id)
        errors[index] << "ID was already used for other record"
      end
      imported_users << external_id
      begin
        email = array[mapping.fetch(:email)].strip.downcase
        u = User.where(email: email).first_or_initialize
        u.get_default_profile
        u.password = SecureRandom.hex(12)
        u.first_name = array[mapping.fetch(:first_name)].strip
        u.last_name = array[mapping.fetch(:last_name)].strip
        u.external_id = external_id
        begin
          u.created_at = Date.parse(array[mapping.fetch(:created_at)])
        rescue
        end
        expires_at = array[mapping.fetch(:expires_at)]
        begin
          u.expires_at = Date.parse("#{expires_at[0..3]}/#{expires_at[4..5]}").end_of_month
        rescue
          errors[index] << "cannot set expire at (#{expires_at})"
          next
        end
        u.mobile_number = array[mapping.fetch(:phone)]
        begin
          date = array[mapping.fetch(:date_of_birth)].to_s
          year = date[-4..-1]
          day = date[-6..-5]
          month = date[0..-7]
          u.default_profile.properties[:date_of_birth] = Date.parse("#{year}-#{month}-#{day}")
        rescue
        end
        member_since = array[mapping.fetch(:member_since)]
        begin
          u.default_profile.properties[:member_since] = Date.parse("#{member_since[0..3]}/#{member_since[4..5]}")
        rescue
        end
        u.default_profile.properties[:member_year] = array[mapping.fetch(:member_year)]
        if u.valid?
          u.save!
        else
          errors[index] << "Invalid rekord: #{u.errors.full_messages.join(', ')}"
        end
      rescue ActiveRecord::RecordInvalid
        puts "\t##{index} - Invalid record #{u.errors.full_messages.join(', ')}"
      end
      if errors[index].empty?
        good_records << index
        puts "\t##{index} - All good!"
      else
        puts "\t##{index} - Had Errors!"
      end
    end
    puts "Good records: #{good_records.count}"
    puts "Errors: "
    puts errors.each do |i, errors|
      puts "##{i}: #{errors.join(';')}"
    end
  end

  task update_users: [:environment] do
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
    KOC_EMAILS = ['abbeyeco@msn.com', 'aimeestairs@yahoo.com', 'highlandqueen@comcast.net', 'smileyajd@yahoo.com', 'tmcolletti@optonline.net', 'pattersog002@hawaii.rr.com', 'rbhall74@aol.com', 'bettypeach@msn.com', 'b_spottek@hotmail.com', 'lilpouters@aol.com', 'hallmarktoys1@cox.net', 'dodgersfan12345@yahoo.com', 'squirrel7@mindspring.com', 'ahlborn4843@comcast.net', 'cheryl.cochran@hctnschools.com', 'doxiedub@gmail.com', 'chrisr05@sbcglobal.net', 'currec405@gmail.com', 'dakcmo@gmail.com', 'dporter82700@hotmail.com', 'dschultz56@cox.net', 'dthomeunit@suddenlink.net', 'ddstikes@hotmail.com', 'hallmark1231@hotmail.com', 'maxysdad@hotmail.com', 'drice2@hallmark.com', 'saintj@caltech.edu', 'dyza10@aol.com', 'ddmurch@aol.com', 'daday@fuse.net', 'doris@sti.net', 'edward_pease@comcast.net', 'elaynabenton@yahoo.com', 'hallmarketeer@hotmail.com', 'lrupert@comcast.net', 'franwoodside@sbcglobal.net', 'fmhogg2004@yahoo.com', 'irgail2@yahoo.com', 'gvickery@tx.rr.com', 'geraldlalmquist@aol.com', 'geritoberman@gmail.com', 'collector@cableone.net', 'hartman_k@atlanticbb.net', 'heathermj@mindspring.com', 'purplepink711@comcast.net', 'hallmarkholly@yahoo.com', 'talariconc@yahoo.com', 'mi3boyz@hotmail.com', 'flanagan55@charter.net', 'jeanie@cox.net', 'jmrudy74@yahoo.com', 'ljandy@yahoo.com', 'jjcburroughs@yahoo.com', 'jwlak@mindspring.com', 'jbro@comcast.net', 'jerrydetimmerman1@gmail.com', 'jhorton100@aol.com', 'jedeyo@hotmail.com', 'jodiemarxlolly@cox.net', 'cjp@everestkc.net', 'jhiles@fuse.net', 'jdree@verizon.net', 'kholthe@aol.com', 'goulddk@embarqmail.com', 'kbrindley1@comcast.net', 'bnkdel@yahoo.com', 'kbware@sw.rr.com', 'alanprenger@embarqmail.com', 'hallmark@rainbowbrite.net', 'kaylamichele9@yahoo.com', 'khkingrey@hotmail.com', 'lindafay@cableone.net', 'ldcampbe@umich.edu', 'dayl@valornet.com', 'ljd4686@gmail.com', 'lindag87124@yahoo.com', 'huntt1961@gmail.com', 'jlkearns439@centurylink.net', 'sweetpeasmom52@yahoo.com', 'lindrobinson@yahoo.com', 'mlssmith510@gmail.com', 'lrw@triad.rr.com', 'arkroom@centurylink.net', 'lzeller@frontiernet.net', 'lkmax1@frontier.com', 'lynetteboyd01@gmail.com', 'mjjelsma@gmail.com', 'marciammatthews@gmail.com', 'johnson224@comcast.net', 'heartland@eastex.net', 'mchart2000@aol.com', 'd.laing@att.net', 'pmyoung@hughes.net', 'kmegsbug@gmail.com', 'oceanview17mm@gmail.com', 'thejohnsons929@att.net', 'lissaandjojo@yahoo.com', 'mlwinter77@gmail.com', 'mypoohmail@yahoo.com', 'micheleneff@hotmail.com', 'missesimpson@sc.rr.com', 'nancy.m.erle@gmail.com', 'nancyg@netease.net', 'nphil316@aol.com', 'jdreasor@charter.net', 'nancy@scvhallmark.com', 'gmom1953@suddenlink.net', 'njcook48@att.net', 'lgorday@centurytel.net', 'cgpgdoyle@cox.net', 'paulaf4958@aol.com', 'peggyavellar@att.net', 'hallmarkfanatic@yahoo.com', 'rphilips122@verizon.net', 'ramicallef@gmail.com', 'rickyhedrick@yahoo.com', 'rderga@gmail.com', 'bubbles_52_us@yahoo.com', 'wolferob@yahoo.com', 'tadrjd@woh.rr.com', 'rose_edgar_1999@yahoo.com', 'rpalmer2002@aol.com', 'kingtutan@aol.com', 'greeneggsforsam@msn.com', 'sre2srl@yahoo.com', 'onehecticmom@hotmail.com', 'kmh4844@gmail.com', 'princessk070@yahoo.com', 'sarahmorin502@gmail.com', 'sean.burks@gmail.com', 'seanmccully@me.com', 'bsbitting@cox.net', 'sizzyyick@hotmail.com' 'stacey.e.schwab@gmail.com', 'sfjm@verizon.net', 'olensven@hotmail.com', 'hallmarkqueen16@yahoo.com', 'hazelstovey@hotmail.com', 'tdavis3412@aol.com', 'teresa@cjbryan.com', 'weber37027@comcast.net', 'teri7837@sbcglobal.net', 'tjnip@tds.net', 'tplga@comcast.net', 'shaddzz@yahoo.com', 'vezz.email@gmail.com', 'jpfeife@hotmail.com', 'wcubes@me.com', 'wernst40@yahoo.com', 'yvonnehanks@anbtx.com']
    path = Rails.root.join('marketplaces', 'hallmark', 'KOC_06Mar.txt')
    emails = []
    CSV.foreach(path, col_sep: '|') do |array|
      unless array[FIRST_NAME] == 'CNSMR_FIRST_NM'
        email = array[EMAIL].downcase.strip
        if email.include?('@')
          emails << email
          u = User.where('email ilike ?', email).first_or_initialize
          if u.persisted?
            puts "skipping #{email} - already added"
            next
          end
          puts "importing: #{email}"
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
    puts "Imported in total: #{emails.count} users"
    users_invalidated = User.not_admin.
                             where.not(email: emails + KOC_EMAILS).
                             where.not('email ilike ?', '%@hallmark.com').
                             update_all(expires_at: nil)
    puts "Invalidating #{users_invalidated} users - setting expires at to nil"
  end
end
