require 'test_helper'

class WorkflowAlertLoggerTest < ActiveSupport::TestCase
  context 'db log' do
    setup do
      WorkflowAlertLogger.setup { |config| config.logger_type = :db }
    end

    should 'get log in db email alert' do
      @email_alert = FactoryGirl.create(:workflow_alert)
      assert_difference 'WorkflowAlertLog.count' do
        WorkflowAlertLogger.new(@email_alert).log!
      end
    end

    should 'get log in db sms alert' do
      @sms_alert = FactoryGirl.create(:workflow_alert_sms)
      assert_difference 'WorkflowAlertLog.count' do
        WorkflowAlertLogger.new(@sms_alert).log!
      end
    end

    context 'aggregate' do
      should 'correctly weekly aggregate two sms alerts' do
        @sms_alert = FactoryGirl.create(:workflow_alert_sms)
        assert_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
          2.times { WorkflowAlertLogger.new(@sms_alert).log! }
        end
        assert_equal 2, WorkflowAlertWeeklyAggregatedLog.last.sms_count
        assert_equal 0, WorkflowAlertWeeklyAggregatedLog.last.email_count
      end

      should 'correctly monthly aggregate two sms alerts' do
        @sms_alert = FactoryGirl.create(:workflow_alert_sms)
        assert_difference 'WorkflowAlertMonthlyAggregatedLog.count' do
          2.times { WorkflowAlertLogger.new(@sms_alert).log! }
        end
        assert_equal 2, WorkflowAlertMonthlyAggregatedLog.last.sms_count
        assert_equal 0, WorkflowAlertMonthlyAggregatedLog.last.email_count
      end

      should 'correctly weekly aggregate two email alerts' do
        @email_alert = FactoryGirl.create(:workflow_alert)
        assert_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
          2.times { WorkflowAlertLogger.new(@email_alert).log! }
        end
        assert_equal 0, WorkflowAlertMonthlyAggregatedLog.last.sms_count
        assert_equal 2, WorkflowAlertMonthlyAggregatedLog.last.email_count
      end

      should 'correctly monthly aggregate two email alerts' do
        @email_alert = FactoryGirl.create(:workflow_alert)
        assert_difference 'WorkflowAlertMonthlyAggregatedLog.count' do
          2.times { WorkflowAlertLogger.new(@email_alert).log! }
        end
        assert_equal 0, WorkflowAlertMonthlyAggregatedLog.last.sms_count
        assert_equal 2, WorkflowAlertMonthlyAggregatedLog.last.email_count
      end

      context 'week number' do
        should 'correctly agregated based on week number' do
          @email_alert = FactoryGirl.create(:workflow_alert)
          @base_date = Time.zone.local(2013, 1, 27, 10, 5)
          assert_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
            travel_to @base_date do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          assert_no_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
            travel_to @base_date + 6.days do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          workflow_alert_for_5th_week = WorkflowAlertWeeklyAggregatedLog.last
          assert_equal 2, workflow_alert_for_5th_week.email_count
          assert_equal 0, workflow_alert_for_5th_week.sms_count
          assert_equal 4, workflow_alert_for_5th_week.week_number
          assert_equal 2013, workflow_alert_for_5th_week.year
          assert_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
            travel_to @base_date + 7.days do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          assert_equal 2, workflow_alert_for_5th_week.reload.email_count
          workflow_alert_for_6th_week = WorkflowAlertWeeklyAggregatedLog.last
          assert_equal 1, workflow_alert_for_6th_week.email_count
          assert_equal 0, workflow_alert_for_6th_week.sms_count
          assert_equal 5, workflow_alert_for_6th_week.week_number
          assert_equal 2013, workflow_alert_for_6th_week.year
        end

        should 'correctly agregated based on month number' do
          @email_alert = FactoryGirl.create(:workflow_alert)
          @base_date = Time.zone.local(2013, 1, 27, 10, 5)
          assert_difference 'WorkflowAlertMonthlyAggregatedLog.count' do
            travel_to @base_date do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          workflow_alert_for_1st_month = WorkflowAlertMonthlyAggregatedLog.last
          assert_equal 1, workflow_alert_for_1st_month.email_count
          assert_equal 0, workflow_alert_for_1st_month.sms_count
          assert_equal 1, workflow_alert_for_1st_month.month
          assert_equal 2013, workflow_alert_for_1st_month.year
          assert_difference 'WorkflowAlertMonthlyAggregatedLog.count' do
            travel_to @base_date + 6.days do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          assert_difference 'WorkflowAlertWeeklyAggregatedLog.count' do
            travel_to @base_date + 7.days do
              WorkflowAlertLogger.new(@email_alert).log!
            end
          end
          assert_equal 1, workflow_alert_for_1st_month.reload.email_count
          workflow_alert_for_2nd_month = WorkflowAlertMonthlyAggregatedLog.last
          assert_equal 2, workflow_alert_for_2nd_month.email_count
          assert_equal 0, workflow_alert_for_2nd_month.sms_count
          assert_equal 2, workflow_alert_for_2nd_month.month
          assert_equal 2013, workflow_alert_for_2nd_month.year
        end
      end
    end

    teardown do
      WorkflowAlertLogger.setup { |config| config.logger_type = :none }
    end
  end
end
