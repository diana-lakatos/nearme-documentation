class Location < ActiveRecord::Base

  class MissingLocation < StandardError; end

  has_many :workplaces

  def self.find_or_create_by_geocode(address)
    location = Geocode.search(address).try(:first)
    raise MissingLocation if location.nil?
    where(location.parts).first || Location.create({ :latitude => location.latitude, :longitude => location.longitude, :name => location.name }.merge(location.parts))
  end

end
