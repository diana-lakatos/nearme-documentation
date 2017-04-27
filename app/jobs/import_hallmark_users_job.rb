# frozen_string_literal: true
require 'aws-sdk'
require 'slack-notifier'
class ImportHallmarkUsersJob < Job
  BUCKET_NAME = 'hallmark-sftp'
  EXTERNAL_ID = 0
  FIRST_NAME = 1
  LAST_NAME = 2
  EMAIL = 3
  DOB = 4
  PHONE = 5
  MEMBER_SINCE = 6
  EXPIRES_AT = 7
  MEMBER_YEAR = 8
  include Job::LongRunning

  def perform
    return unless Rails.env.production?
    instance = Instance.find_by(id: Instances::InstanceFinder::INSTANCE_IDS[:hallmark])
    return if instance.nil?
    instance.set_context!
    @date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date.strftime('%Y%m%d')
    notifier.ping("Starting importing file for: #{@date}", icon_emoji: ':sweat:')

    client = Aws::S3::Client.new(region: 'us-west-2',
                                 credentials: Aws::Credentials.new(ENV['HALLMARK_ACCESS_KEY_ID'], ENV['HALLMARK_ACCESS_KEY_SECRET']))

    objects = client.list_objects(bucket: BUCKET_NAME,
                                  prefix: "KOC_#{@date}")

    key = objects&.contents&.first&.key
    if key.nil?
      notifier.ping(':rage::rage::rage: No file found for :rage::rage::rage:', icon_emoji: ':sweat:')
    else
      begin
        file = Tempfile.new('hallmark')
        client.get_object(bucket: BUCKET_NAME, key: key) do |chunk|
          file.write(chunk)
        end

        emails = []
        CSV.foreach(file, col_sep: '|') do |array|
          unless array[FIRST_NAME] == 'CNSMR_FIRST_NM'
            email = array[EMAIL].to_s.downcase.strip
            if email.include?('@')
              emails << email
              u = User.where('email ilike ?', email).first_or_initialize
              u.expires_at = begin
                               Date.strptime(array[EXPIRES_AT], '%Y%m').end_of_month
                             rescue
                               logger.info "\tCRITICAL ISSUE: expires date is invalid - #{array[EXPIRES_AT]}"
                               next
                             end
              if u.persisted?
                logger.info "updating: #{email}"
              else
                logger.info "importing: #{email}"
              end
              u.email = email
              u.password = SecureRandom.hex(12) unless u.encrypted_password.present?
              u.external_id = array[EXTERNAL_ID]
              u.get_default_profile
              if u.properties.date_of_birth.blank?
                u.properties.date_of_birth = begin
                                               Date.strptime(array[DOB], '%m%d%Y')
                                             rescue
                                               logger.info "\tInvalid DOB: #{array[DOB]}"
                                               nil
                                             end
              end
              if u.properties.member_since.blank?
                u.properties.member_since = begin
                                              Date.strptime(array[MEMBER_SINCE], '%Y%m')
                                            rescue
                                              logger.info "\tInvalid MEMBER_SINCE: #{array[MEMBER_SINCE]}"
                                              nil
                                            end
              end
              u.properties.member_year = array[MEMBER_YEAR] if u.properties.member_year.blank?
              u.mobile_number = array[PHONE] if u.mobile_number.blank?
              u.first_name = array[FIRST_NAME].humanize if u.first_name.blank?
              u.last_name = array[LAST_NAME].humanize if u.last_name.blank?
              u.verified_at = Time.now unless u.verified_at.present?
              logger.info "\tERROR!!! #{u.expires_at} not in the future" if u.expires_at < Time.now
              if u.save
                if u.metadata['verification_email_sent_at'].blank?
                  logger.info "\tSending email to: #{u.email}"
                  WorkflowAlert::InvokerFactory.get_invoker(WorkflowAlert.find(133_65)).invoke!(WorkflowStep::SignUpWorkflow::AccountCreated.new(u.id))
                  u.metadata['verification_email_sent_at'] = Time.zone.now
                  u.save!
                end
              else
                logger.info "\tCRITICAL ISSUE: user was not saved - #{u.errors.full_messages.join(', ')}"
              end
            else
              logger.info "Skipping due to email: #{email}; external_id: #{array[EXTERNAL_ID]}"
            end
          end
        end
        logger.info "Imported in total: #{emails.count} users"
      ensure
        file.close
        file.unlink
      end
      File.open("#{Rails.root}/log/downloading_koc_#{@date}.log", 'rb') do |file|
        client.put_object(bucket: BUCKET_NAME, key: "logs/#{@date}.log", body: file)
      end
      notifier.ping(':sweat_smile::sweat_smile::sweat_smile: I guess users were imported correctly :sweat_smile::sweat_smile::sweat_smile:', icon_emoji: ':sweat:')
    end
  end

  protected

  def logger
    @logger = Logger.new("#{Rails.root}/log/downloading_koc_#{@date}.log")
  end

  def notifier
    @notifier ||= Slack::Notifier.new('https://hooks.slack.com/services/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')
  end
end
