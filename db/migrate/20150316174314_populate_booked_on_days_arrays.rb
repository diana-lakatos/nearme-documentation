class PopulateBookedOnDaysArrays < ActiveRecord::Migration
  def change
    Location.reset_column_information
    Transactable.reset_column_information
    Instance.find_each do |i|
      PlatformContext.current = PlatformContext.new(i)
      puts "Populating all locations for #{i.name}"
      Location.find_each { |l| l.save(validate: false) }
      puts "Populating all transactables for #{i.name}"
      Transactable.find_each { |l| l.save(validate: false) }
    end
  end
end
