require 'test_helper'

class DataUploadMailerTest < ActiveSupport::TestCase

  setup do
    stub_mixpanel
    @platform_context = PlatformContext.current
    @instance = @platform_context.instance
    PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
  end

  should 'failed data_upload' do
    @data_upload = FactoryGirl.create(:data_upload_with_encountered_error)
    mail = DataUploadMailer.notify_uploader_of_failed_import(@data_upload)
    assert_equal "Importing '#{@data_upload.csv_file_identifier}' has failed", mail.subject
    assert_equal [@data_upload.uploader.email], mail.to
    assert mail.html_part.body.include?("We were not able to import data")
  end

  context 'finished data upload' do

    should 'finished data_upload without validation errors' do
      @data_upload = FactoryGirl.create(:data_upload_with_report)
      mail = DataUploadMailer.notify_uploader_of_finished_import(@data_upload)
      assert_equal "Importing '#{@data_upload.csv_file_identifier}' has finished", mail.subject
      assert_equal [@data_upload.uploader.email], mail.to
      assert_contains "It started on #{ I18n.l(@data_upload.imported_at, format: :long)} and finished on #{ I18n.l(@data_upload.updated_at, format: :long)}", mail.html_part.body
      assert_not_contains "Encountered validation errors log", mail.html_part.body
      assert_contains "New entities: User: 0, Company: 0, Location: 2, Transactable: 3, Photo: 4", mail.html_part.body
      assert_contains "Updated entities: User: 0, Company: 0, Location: 9, Transactable: 8, Photo: 7", mail.html_part.body
      assert_contains "Deleted entities: User: 1", mail.html_part.body

      assert_contains "http://custom.domain.com/dashboard/transactable_types/#{@data_upload.transactable_type.id}/transactables/new", mail.html_part.body
      assert_not_contains 'http://example.com', mail.html_part.body

      assert_contains "It started on #{ I18n.l(@data_upload.imported_at, format: :long)} and finished on #{ I18n.l(@data_upload.updated_at, format: :long)}", mail.text_part.body
      assert_not_contains "Encountered validation errors log", mail.text_part.body
      assert_contains "New entities: User: 0, Company: 0, Location: 2, Transactable: 3, Photo: 4", mail.text_part.body
      assert_contains "Updated entities: User: 0, Company: 0, Location: 9, Transactable: 8, Photo: 7", mail.text_part.body
      assert_contains "Deleted entities: User: 1", mail.text_part.body
      assert_contains "http://custom.domain.com/dashboard/transactable_types/#{@data_upload.transactable_type.id}/transactables/new", mail.text_part.body
      assert_not_contains 'http://example.com', mail.html_part.body
    end

    should 'not include deleted if irrelevant' do
      @data_upload = FactoryGirl.create(:data_upload_with_report_without_delete)
      mail = DataUploadMailer.notify_uploader_of_finished_import(@data_upload)
      refute mail.html_part.body.include?("Deleted enities")
      refute mail.text_part.body.include?("Deleted enities")

    end

    should 'finished data_upload with validation errors' do
      @data_upload = FactoryGirl.create(:data_upload_with_validation_errors)
      mail = DataUploadMailer.notify_uploader_of_finished_import(@data_upload)
      assert_equal "Importing '#{@data_upload.csv_file_identifier}' has finished", mail.subject
      assert_equal [@data_upload.uploader.email], mail.to

      assert_contains "Encountered validation errors log", mail.html_part.body
      assert_contains "Validation error for Transactable 3178: some error. Ignoring all children.<br", mail.html_part.body
      assert_contains "Validation error for Transactable 3179: another error. Ignoring all children.", mail.html_part.body

      assert_contains "Encountered validation errors log", mail.text_part.body
      assert_contains "Validation error for Transactable 3178: some error. Ignoring all children.", mail.text_part.body
      assert_contains "Validation error for Transactable 3179: another error. Ignoring all children.", mail.text_part.body

    end
  end

end

