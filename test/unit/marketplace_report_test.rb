require 'test_helper'

class MarketplaceReportTest < ActiveSupport::TestCase
  setup do
    Transactable.delete_all
    User.delete_all

    @transactable_1 = FactoryGirl.create(:transactable, name: 'First transactable')
    @transactable_2 = FactoryGirl.create(:transactable, name: 'Second transactable')
    @user_1 = FactoryGirl.create(:user, first_name: 'First_user')
    @user_2 = FactoryGirl.create(:user, first_name: 'Second user')
  end

  should 'have correct transactables' do
    # This is to avoid running zip, stubbing CompressedZipReport
    # we need to keep this here as data will be assigned after the job is performed
    data = nil
    format = nil
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:initialize).with do |data_param, format_param|
      data = data_param
      format = format_param
    end
    file_path = File.join(Rails.root, 'tmp', 'data.csv')
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:compress).with do
      write_data_to_file(file_path, data)
    end
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:compress).returns(file_path)

    marketplace_report = MarketplaceReport.create(report_type: 'Transactable',
                                                  creator: User.last,
                                                  report_parameters: {:search_by_query=>[["name", "description", "properties"], "%Second%"]})
    MarketplaceReportsCreatorJob.perform(marketplace_report.id)

    marketplace_report.reload

    assert_equal 'created', marketplace_report.state

    csv_array = CSV.parse(data)

    assert_equal 'Second transactable', csv_array[1][33]
    assert_equal 2, csv_array.length

    marketplace_report.remove_zip_file!
    marketplace_report.destroy
  end

  should 'have correct users' do
    # This is to avoid running zip, stubbing CompressedZipReport
    # we need to keep this here as data will be assigned after the job is performed
    data = nil
    format = nil
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:initialize).with do |data_param, format_param|
      data = data_param
      format = format_param
    end
    file_path = File.join(Rails.root, 'tmp', 'data.csv')
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:compress).with do
      write_data_to_file(file_path, data)
    end
    MarketplaceReports::CompressedZipReport.any_instance.stubs(:compress).returns(file_path)

    marketplace_report = MarketplaceReport.create(report_type: 'User',
                                                  creator: User.last,
                                                  report_parameters: {:not_admin=>nil, :by_search_query=>["%Second%"]})
    MarketplaceReportsCreatorJob.perform(marketplace_report.id)

    marketplace_report.reload

    assert_equal 'created', marketplace_report.state

    csv_array = CSV.parse(data)

    assert_equal 'Second user', csv_array[1][56]
    assert_equal 2, csv_array.length

    marketplace_report.remove_zip_file!
    marketplace_report.destroy
  end

  private

  def write_data_to_file(file_path, data)
    File.open(file_path, 'w') do |f|
      f.write(data)
    end
  end
end
