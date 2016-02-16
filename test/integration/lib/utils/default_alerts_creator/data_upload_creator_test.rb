require 'test_helper'

class Utils::DefaultAlertsCreator::DataUploadCreatorTest < ActionDispatch::IntegrationTest

  setup do
    @data_upload_creator = Utils::DefaultAlertsCreator::DataUploadCreator.new
  end

  should 'create all' do
    @data_upload_creator.expects(:notify_uploader_of_failed_import_email!).once
    @data_upload_creator.expects(:notify_uploader_of_finished_import_email!).once
    @data_upload_creator.create_all!
  end

  context 'methods' do

    setup do
      @platform_context = PlatformContext.current
      @instance = @platform_context.instance
      PlatformContext.any_instance.stubs(:domain).returns(FactoryGirl.create(:domain, :name => 'custom.domain.com'))
    end

    should 'failed data_upload' do
      @data_upload_creator.notify_uploader_of_failed_import_email!
      @data_upload = FactoryGirl.create(:data_upload_with_encountered_error)
      assert_difference 'ActionMailer::Base.deliveries.size' do
        WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Failed, @data_upload.id)
      end
      mail = ActionMailer::Base.deliveries.last
      assert_equal "[#{@platform_context.decorate.name}] Importing '#{@data_upload.csv_file_identifier}' has failed", mail.subject
      assert_equal [@data_upload.uploader.email], mail.to
      assert mail.html_part.body.include?("We were not able to import data")
      assert_not_contains 'Liquid error:', mail.html_part.body
    end

    context 'finished data upload' do

      setup do
        @data_upload_creator.notify_uploader_of_finished_import_email!
      end

      should 'finished data_upload without validation errors' do
        @data_upload = FactoryGirl.create(:data_upload_with_report)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Finished, @data_upload.id)
        end
        mail = ActionMailer::Base.deliveries.last
        assert_equal "[#{@platform_context.decorate.name}] Importing '#{@data_upload.csv_file_identifier}' has finished", mail.subject
        assert_equal [@data_upload.uploader.email], mail.to
        assert_contains "It started on #{ I18n.l(@data_upload.imported_at, format: :long)} and finished on #{ I18n.l(@data_upload.updated_at, format: :long)}", mail.html_part.body
        assert_not_contains "Encountered validation errors log", mail.html_part.body
        assert_contains "New entities: User: 0, Company: 0, Location: 2, Transactable: 3, Photo: 4", mail.html_part.body
        assert_contains "Updated entities: User: 0, Company: 0, Location: 9, Transactable: 8, Photo: 7", mail.html_part.body
        assert_contains "Deleted entities: User: 1", mail.html_part.body
        assert_contains "href=\"https://custom.domain.com/dashboard/company/transactable_types/#{@data_upload.importable.slug}/transactables/new", mail.html_part.body
        assert_not_contains 'href="https://example.com', mail.html_part.body
        assert_not_contains 'href="/', mail.html_part.body

        assert_contains "It started on #{ I18n.l(@data_upload.imported_at, format: :long)} and finished on #{ I18n.l(@data_upload.updated_at, format: :long)}", mail.text_part.body
        assert_not_contains "Encountered validation errors log", mail.text_part.body
        assert_contains "New entities: User: 0, Company: 0, Location: 2, Transactable: 3, Photo: 4", mail.text_part.body
        assert_contains "Updated entities: User: 0, Company: 0, Location: 9, Transactable: 8, Photo: 7", mail.text_part.body
        assert_contains "Deleted entities: User: 1", mail.text_part.body
        assert_contains "https://custom.domain.com/dashboard/company/transactable_types/#{@data_upload.importable.slug}/transactables/new", mail.text_part.body
      end

      should 'not include deleted if irrelevant' do
        @data_upload = FactoryGirl.create(:data_upload_with_report_without_delete)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Finished, @data_upload.id)
        end
        mail = ActionMailer::Base.deliveries.last
        refute mail.html_part.body.include?("Deleted enities")
        refute mail.text_part.body.include?("Deleted enities")

      end

      should 'finished data_upload with validation errors' do
        @data_upload = FactoryGirl.create(:data_upload_with_validation_errors)
        assert_difference 'ActionMailer::Base.deliveries.size' do
          WorkflowStepJob.perform(WorkflowStep::DataUploadWorkflow::Finished, @data_upload.id)
        end
        mail = ActionMailer::Base.deliveries.last
        assert_equal "[#{@platform_context.decorate.name}] Importing '#{@data_upload.csv_file_identifier}' has finished", mail.subject
        assert_equal [@data_upload.uploader.email], mail.to

        assert_contains "Encountered validation errors log", mail.html_part.body
        assert_contains "Validation error for Transactable 3178: some error. Ignoring all children.<br", mail.html_part.body
        assert_contains "Validation error for Transactable 3179: another error. Ignoring all children.", mail.html_part.body

        assert_contains "Encountered validation errors log", mail.text_part.body
        assert_contains "Validation error for Transactable 3178: some error. Ignoring all children.", mail.text_part.body
        assert_contains "Validation error for Transactable 3179: another error. Ignoring all children.", mail.text_part.body
        assert_not_contains 'Liquid error:', mail.html_part.body

      end
    end

  end

end

