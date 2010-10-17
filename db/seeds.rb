# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

locations = {
  'Icelab' => 'Unit 3, The Metropolitan, 1 Gordon St, Canberra City, ACT 2601 Australia',
  'Thoughtworks Chicago' => '200 E Randolph St, 25th Floor, Chicago, IL 60601-6501, USA',
  'Thoughtworks San Francisco' => '315 Montgomery Street, 16th Floor, San Francisco, CA 94104, USA'
}
user = User.create!(:name => "Desks Near Me", :email => "desksnearme@gmail.com")
locations.each do |name, location|
  Workplace.create!(:name => name, :creator => user, :maximum_desks => rand(20), :address => location, :company_description => "We're #{name}, and we rock the party!", :description => "Dont muck around at #{name}, we'll beat you up!")
end

