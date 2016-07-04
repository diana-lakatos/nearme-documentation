desc "Fix custom csv fields fr Service Types"
task fix_custom_csv_fields: :environment do
  counter = 0

  Instance.find_each do |instance|
    PlatformContext.current = PlatformContext.new(instance)

    TransactableType.find_each do |service_type|
      if ndx = service_type.custom_csv_fields.index('transactable' => 'listing_type')
        service_type.custom_csv_fields[ndx] = {'listing_type' => 'name'}
        service_type.save! validate: false
        counter += 1
      end
    end
  end

  puts "#{counter} service types changed"
end
