FactoryGirl.define do
  factory :host_csv_template_file, class: DataImporter::Host::CsvFile::TemplateCsvFile  do
    skip_create

    initialize_with do
      FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
      new(DataUpload.create(uploader: FactoryGirl.create(:user, name: 'UserName UserLast', email: 'user-name@example.com'), importable: FactoryGirl.create(:transactable_type_csv_template), csv_file: File.open(Rails.root.join('test', 'assets', 'data_importer', 'csv', 'csv_template_file.csv'))))
    end
  end

  factory :csv_template_file, class: DataImporter::CsvFile::TemplateCsvFile  do
    skip_create

    initialize_with do
      FactoryGirl.create(:location_type, name: 'My Type') unless LocationType.where(name: 'My Type').count > 0
      new(
        FactoryGirl.create(:data_upload,
          csv_file: fixture_file_upload(Rails.root.join('test', 'assets', 'data_importer', 'csv', 'csv_template_file.csv'), 'text/csv'),
          importable: FactoryGirl.create(:transactable_type_csv_template)
        )
      )
    end
  end

  factory :xml_template_file, class: DataImporter::XmlFile  do
    skip_create

    initialize_with do
      new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file.xml'), FactoryGirl.create(:transactable_type_csv_template))
    end

    factory :host_xml_template_file_invalid_transactable do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'host', 'host_xml_template_file_invalid_transactable.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :host_xml_template_file do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'host', 'host_xml_template_file.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :xml_template_file_send_invitations  do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file.xml'), FactoryGirl.create(:transactable_type_csv_template), { inviter: DataImporter::Inviter.new })
      end
    end

    factory :xml_template_file_sync_mode_invalid_transactable do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_invalid_transactable.xml'), FactoryGirl.create(:transactable_type_csv_template), { synchronizer: DataImporter::Synchronizer.new })
      end
    end

    factory :xml_template_file_sync_mode do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file.xml'), FactoryGirl.create(:transactable_type_csv_template), { synchronizer: DataImporter::Synchronizer.new })
      end
    end

    factory :xml_template_file_invalid_company do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_invalid_company.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :xml_template_file_no_valid_users do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_no_valid_users.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :xml_template_file_invalid_location do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_invalid_location.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :xml_template_file_invalid_location_address do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_invalid_location_address.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

    factory :xml_template_file_invalid_transactable do
      initialize_with do
        new(Rails.root.join('test', 'assets', 'data_importer', 'xml', 'xml_template_file_invalid_transactable.xml'), FactoryGirl.create(:transactable_type_csv_template))
      end
    end

  end
end

