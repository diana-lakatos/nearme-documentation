class AddressComponentName < ActiveRecord::Base
  attr_accessible :location, :long_name, :short_name


  validates_presence_of :short_name, :long_name

  belongs_to :location

  has_and_belongs_to_many :address_component_types

end
