# frozen_string_literal: true
require 'aws-sdk'
require 'slack-notifier'
class ExportDevmeshDataJob < Job
  BUCKET_NAME = 'devmesh-ingest'
  include Job::LongRunning

  def perform
    return if ENV['DEVMESH_ACCESS_KEY_ID'].blank? || ENV['DEVMESH_ACCESS_KEY_SECRET'].blank?
    instance = Instance.find_by(id: Instances::InstanceFinder::INSTANCE_IDS[:devmesh])
    return if instance.nil?
    instance.set_context!

    @date = Time.now.in_time_zone('Pacific Time (US & Canada)').to_date.strftime('%Y%m%d')
    notifier.ping("Starting exporting data for: #{@date}", icon_emoji: ':sweat:')

    client = Aws::S3::Client.new(region: 'us-east-1',
                                 credentials: Aws::Credentials.new(ENV['DEVMESH_ACCESS_KEY_ID'],
                                                                   ENV['DEVMESH_ACCESS_KEY_SECRET']))

    [{ report_type: 'User',
       report_parameters: {
         not_admin: nil
       } },
     { report_type: 'Transactable',
       report_parameters: {} }].each do |report_hash|
      MarketplaceReports::MarketplaceReportsGenerator.new(type: report_hash[:report_type],
                                                          params: report_hash[:report_parameters]).generate_report_file do |file_path|
        File.open(file_path) do |f|
          client.put_object(bucket: BUCKET_NAME, key: "#{@date}/#{report_hash[:report_type].downcase}.zip", body: f)
        end
      end
    end
    notifier.ping(' I guess data was exported correctly ', icon_emoji: ':sweat_smile:')
  rescue => e
    job.notifier("Job failed due to #{e} #{e.message} (#{backtrace.detect { |l| l.include?('/app/') }})", icon_emoji: ':cry:')
  end

  protected

  def notifier
    @notifier ||= Slack::Notifier.new('https://hooks.slack.com/services/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')
  end
end
