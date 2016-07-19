desc "Fix custom csv fields fr Service Types"
task fix_custom_csv_fields: :environment do
  counter = 0

  Instance.find_each do |instance|
    PlatformContext.current = PlatformContext.new(instance)

    TransactableType.find_each do |transactable_type|
      if ndx = transactable_type.custom_csv_fields.index('transactable' => 'listing_type')
        transactable_type.custom_csv_fields[ndx] = {'listing_type' => 'name'}
        transactable_type.save! validate: false
        counter += 1
      end
    end
  end

  puts "#{counter} service types changed"
end
