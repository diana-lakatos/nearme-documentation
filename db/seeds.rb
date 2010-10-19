# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

if User.all.empty?
  puts "No users"
  exit
end

200.times do |i|
  Workplace.create!( { :name => "Workplace #{i}", :maximum_desks => 10, :latitude => -34.705022, :longitude => 138.710672, :address => "34 olinda st craigmore", :creator => User.first } )
end
