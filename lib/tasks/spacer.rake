require "nearme/backup"
# require 'mocha/mini_test'

namespace :spacer do
  namespace :test do
    desc 'Test monthly payment'
    task payments: :environment do
      print "\n\nSetting up test environment...\n"
      quietly do
        Rails.env = ENV['RAILS_ENV'] = 'test'
        ActiveRecord::Base.establish_connection
        pathname = Rails.root + Pathname.new('tmp/backup.dump')
        NearMe::Backup.new({stack: 'nm-production'}).capture!
        Utils::S3FileHelper.new(pathname).download_file!
        `#{Utils::DatabaseConnectionHelper.new(pathname).build_restore_command}`
      end

      Instance.reset_column_information
      PaymentGateway.primary_key = :id
      Instance.find(130).set_context!
      next_charge_day = Date.today.end_of_month + 1.day
      Time.zone.stubs(:now).returns(next_charge_day.end_of_day)
      Instance.any_instance.stubs(:set_context!).returns(true)
      response = { success?: true }
      PaymentGateway.any_instance.stubs(:gateway_authorize).returns(OpenStruct.new(response.reverse_merge(authorization: '54533')))
      PaymentGateway.any_instance.stubs(:gateway_capture).returns(OpenStruct.new(response.reverse_merge(params: { 'id' => '12345' })))
      CreditCard.any_instance.stubs(:response).returns('')

      RecurringBooking.needs_charge(next_charge_day).each do |rb|
        ScheduleChargeSubscriptionJob.perform(rb.id)
        rb.reload
        period = rb.periods.last
        success = rb.next_charge_date == next_charge_day + 1.month
        success = success && period.paid_at.to_s == next_charge_day.end_of_day.to_s
        success = success && period.payment.paid?
        print success ? '.' : 'F'
        $stdout.flush
      end

      print "\nClearing test database..."
      quietly do
        Rake::Task["db:reset"].execute
      end
      print "\nDone."
    end
  end
end
