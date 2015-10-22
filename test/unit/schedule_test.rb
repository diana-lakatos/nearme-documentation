require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  context 'schedule rules' do

    setup do
      @date = Time.new(2015, 10, 4, 14, 34, 49).in_time_zone
      travel_to(@date) do
        @schedule = FactoryGirl.create(:schedule)
      end
    end

    context 'with specific hours' do

      context 'with recurring dates mode' do

        should 'generate proper schedule' do
          travel_to(@date) do
            @schedule_rule = FactoryGirl.create(:schedule_rule, :specific_hours_mode, :recurring_dates_mode, schedule: @schedule)
            @schedule.create_schedule_from_schedule_rules
            @schedule = Schedule.find(@schedule.id)
            assert_times([
              Time.new(2015, 10, 4, 19, 1, 0),

              Time.new(2015, 10, 5, 10, 25, 0),
              Time.new(2015, 10, 5, 14, 15, 0),
              Time.new(2015, 10, 5, 19, 1, 0),

              Time.new(2015, 10, 9, 10, 25, 0),
              Time.new(2015, 10, 9, 14, 15, 0),
              Time.new(2015, 10, 9, 19, 1, 0),

              Time.new(2015, 10, 11, 10, 25, 0),

            ], 8)
          end
        end

      end

      context 'with specific dates mode' do

        should 'generate proper schedule' do
          travel_to(@date) do
            @schedule_rule = FactoryGirl.create(:schedule_rule, :specific_hours_mode, :specific_dates_mode, schedule: @schedule)
            @schedule.create_schedule_from_schedule_rules
            @schedule = Schedule.find(@schedule.id)
            assert_times([
              Time.new(2015, 10, 4, 19, 1, 0),

              Time.new(2015, 10, 7, 10, 25, 0),
              Time.new(2015, 10, 7, 14, 15, 0),
              Time.new(2015, 10, 7, 19, 1, 0),

              Time.new(2015, 10, 11, 10, 25, 0),
              Time.new(2015, 10, 11, 14, 15, 0),
              Time.new(2015, 10, 11, 19, 1, 0),

            ], 8)
          end
        end

      end

      context 'with date range dates mode' do

        should 'generate proper schedule' do
          travel_to(@date) do
            @schedule_rule = FactoryGirl.create(:schedule_rule, :specific_hours_mode, :date_range_dates_mode, schedule: @schedule)
            @schedule.create_schedule_from_schedule_rules
            @schedule = Schedule.find(@schedule.id)
            assert_times([
              Time.new(2015, 10, 7, 10, 25, 0),
              Time.new(2015, 10, 7, 14, 15, 0),
              Time.new(2015, 10, 7, 19, 1, 0),

              Time.new(2015, 10, 8, 10, 25, 0),
              Time.new(2015, 10, 8, 14, 15, 0),
              Time.new(2015, 10, 8, 19, 1, 0),

              Time.new(2015, 10, 9, 10, 25, 0),
              Time.new(2015, 10, 9, 14, 15, 0),
              Time.new(2015, 10, 9, 19, 1, 0),

            ], 12)
          end
        end

      end
    end

    context 'with combined rules' do

      should 'properly generate schedule without duplicates' do
        travel_to(@date) do
          @schedule_rule = FactoryGirl.create(:schedule_rule, :recurring_hours_mode, :recurring_dates_mode, schedule: @schedule)
          @schedule_rule = FactoryGirl.create(:schedule_rule, :recurring_hours_mode, :date_range_dates_mode, schedule: @schedule)
          @schedule_rule = FactoryGirl.create(:schedule_rule, :specific_hours_mode, :specific_dates_mode, schedule: @schedule)
          @schedule.create_schedule_from_schedule_rules
          @schedule = Schedule.find(@schedule.id)
          assert_times([
            Time.new(2015, 10, 4, 16, 15, 0),
            Time.new(2015, 10, 4, 19, 1, 0),
            Time.new(2015, 10, 4, 19, 30, 0),

            Time.new(2015, 10, 5, 9, 45, 0),
            Time.new(2015, 10, 5, 13, 0, 0),
            Time.new(2015, 10, 5, 16, 15, 0),
            Time.new(2015, 10, 5, 19, 30, 0),

            Time.new(2015, 10, 7, 9, 45, 0),
            Time.new(2015, 10, 7, 10, 25, 0),
            Time.new(2015, 10, 7, 13, 0, 0),
            Time.new(2015, 10, 7, 14, 15, 0),
            Time.new(2015, 10, 7, 16, 15, 0),
            Time.new(2015, 10, 7, 19, 1, 0),
            Time.new(2015, 10, 7, 19, 30, 0),

            Time.new(2015, 10, 8, 9, 45, 0),
            Time.new(2015, 10, 8, 13, 0, 0),
            Time.new(2015, 10, 8, 16, 15, 0),
            Time.new(2015, 10, 8, 19, 30, 0),

            Time.new(2015, 10, 9, 9, 45, 0),
            Time.new(2015, 10, 9, 13, 0, 0),
            Time.new(2015, 10, 9, 16, 15, 0),
            Time.new(2015, 10, 9, 19, 30, 0),

            Time.new(2015, 10, 11, 9, 45, 0),

          ], 23)
        end

      end

    end

    context 'for future years' do

      should 'properly generate schedule without duplicates' do
        travel_to(@date) do
          @schedule_rule = FactoryGirl.create(:schedule_rule, :specific_hours_mode, :specific_dates_mode, :future_years, schedule: @schedule)
          @schedule.create_schedule_from_schedule_rules
          @schedule = Schedule.find(@schedule.id)
          assert_times([
            Time.new(2017, 10, 4, 10, 25, 0),
            Time.new(2017, 10, 4, 14, 15, 0),
            Time.new(2017, 10, 4, 19, 1, 0),

            Time.new(2017, 10, 7, 10, 25, 0),
            Time.new(2017, 10, 7, 14, 15, 0),
            Time.new(2017, 10, 7, 19, 1, 0),

            Time.new(2017, 10, 11, 10, 25, 0),
            Time.new(2017, 10, 11, 14, 15, 0),
            Time.new(2017, 10, 11, 19, 1, 0),

          ], 9)
        end

      end
    end
  end

  protected

  def assert_times(expected_array, number)
    time = @schedule.schedule.first
    times = begin
              if time.to_i == Time.zone.now.to_i
                @schedule.schedule.first(number + 1)[1..number+1]
              else
                @schedule.schedule.first(number)
              end.map { |t| t.in_time_zone }
            end
    assert_equal expected_array.map { |t| t.in_time_zone }, times
  end

end

