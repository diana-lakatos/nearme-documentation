require 'test_helper'

class Utils::DefaultAlertsCreator::SpamReportCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @spam_report_creator = Utils::DefaultAlertsCreator::SpamReportCreator.new
  end

  should 'create all' do
    @spam_report_creator.expects(:create_summary_email!).once
    @spam_report_creator.create_all!
  end

  should 'create summary email' do
    stub_mixpanel
    @platform_context = PlatformContext.current
    @instance = @platform_context.instance
    @instance.is_community = true
    @instance.save!

    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, name: 'custom.domain.com'))
    FactoryGirl.create(:instance_admin)

    @spam_report_creator.create_summary_email!

    datetime = 5.hours.ago.to_date
    Timecop.freeze(datetime) do
      3.times { FactoryGirl.create(:spam_report) }
    end

    assert_difference 'ActionMailer::Base.deliveries.size' do
      WorkflowStepJob.perform(WorkflowStep::SpamReportWorkflow::SummaryStep, SpamReport.count)
    end
    mail = ActionMailer::Base.deliveries.last
    assert_equal "[#{I18n.l(datetime, format: :short)}] - #{SpamReport.count} Spam Reports on #{@platform_context.decorate.name}", mail.subject
    assert mail.html_part.body.include?("There were #{SpamReport.count}")
  end
end
