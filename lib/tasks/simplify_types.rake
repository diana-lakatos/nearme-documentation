namespace :simplify do

  desc "Remove all listing types, add three of them and set the default"
  task :location_types => :environment do
    new_location_type_names =["Business", "Co-working", "Public"] 
    new_location_type_names.each do |name|
      LocationType.create(:name => name) unless LocationType.find_by_name(name)
    end
    business_ids = LocationType.where(['name IN (?)', ["Company Office", "Goverment Space", "Business Center"]]).pluck(:id)
    coworking_ids = LocationType.where(['name IN (?)', ["Shared Office", "Coworking"]]).pluck(:id)
    public_ids = LocationType.where(['name IN (?)', ["Cafe"]]).pluck(:id)
    business_location_type = LocationType.find_by_name('Business')
    coworking_location_type = LocationType.find_by_name('Co-working')
    public_location_type = LocationType.find_by_name('Public')
    Location.update_all({:location_type_id => business_location_type.id}, ['location_type_id IN (?)', business_ids]) if !business_location_type.nil? && !business_ids.empty?
    Location.update_all({:location_type_id => coworking_location_type.id}, ['location_type_id IN (?)', coworking_ids]) if !coworking_location_type.nil? && !coworking_ids.empty?
    Location.update_all({:location_type_id => public_location_type.id}, ['location_type_id IN (?)', public_ids]) if !public_location_type.nil? && !public_ids.empty?
    Location.update_all({:location_type_id => business_location_type.id}, ['location_type_id NOT IN (?)', [business_location_type.id, coworking_location_type.id, public_location_type.id]])
    LocationType.delete_all(['name NOT IN (?)', new_location_type_names])
  end

end
