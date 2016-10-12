include ActionDispatch::TestProcess
FactoryGirl.define do
  factory :data_upload do
    csv_file { fixture_file_upload(Rails.root.join('test', 'assets', 'data_importer', 'sample_data.csv'), 'text/csv') }
    target { (PlatformContext.current.instance || FactoryGirl.create(:instance)) }
    association :uploader, factory: :user
    importable { TransactableType.first || FactoryGirl.create(:transactable_type) }

    factory :data_upload_with_encountered_error do
      encountered_error "#<NoMethodError: undefined method `queue' for #<DataUpload:0x007fdcaba47bf0>>\n\n[\"/sample/stack/trace/activemodel-4.0.8/lib/active_model/attribute_methods.rb:439:in `method_missing'\", \"/sample/stack/trace/activerecord-4.0.8/lib/active_record/attribute_methods.rb:168:in `method_missing'\", \"/app/jobs/data_upload_host_convert_job.rb:17:in `perform'\", \"/app/jobs/job.rb:60:in `perform'\", \"/app/controllers/manage/transactable_types/data_uploads_controller.rb:25:in `create'\", \"/sample/stack/trace/actionpack-4.0.8/lib/action_controller/metal/implicit_render.rb:4:in `send_action'\"]"
      state 'failed'
    end

    factory :data_upload_with_report do
      parse_summary do
        { new: {
          'user' => 0,
          'company' => 0,
          'location' => 2,
          'transactable' => 3,
          'photo' => 4
        },
          updated: {
            'user' => 0,
            'company' => 0,
            'location' => 9,
            'transactable' => 8,
            'photo' => 7
          },
          deleted: {
            'user' => 1
          } }
      end
      imported_at { Time.zone.now - 1.hour }
      state 'succeeded'

      factory :data_upload_with_report_without_delete do
        parse_summary do
          { new: {
            'user' => 0,
            'company' => 0,
            'location' => 2,
            'transactable' => 3,
            'photo' => 4
          },
            updated: {
              'user' => 0,
              'company' => 0,
              'location' => 9,
              'transactable' => 8,
              'photo' => 7
            }
        }
        end
      end

      factory :data_upload_with_validation_errors do
        parsing_result_log "Validation error for Transactable 3178: some error. Ignoring all children.\nValidation error for Transactable 3179: another error. Ignoring all children.\n"
        state 'partially_succeeded'
      end
    end
  end
end
