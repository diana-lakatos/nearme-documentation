class AddNameToLocation < ActiveRecord::Migration

  class Company < ActiveRecord::Base
    has_many :locations, inverse_of: :company
  end

  class Location < ActiveRecord::Base
    belongs_to :company, inverse_of: :locations

    def street
      super.presence || address.try{|a| a.split(",")[0] }
    end

    def address
      read_attribute(:formatted_address).presence || read_attribute(:address)
    end

    def build_name
      [company.name, street].compact.join(" @ ")
    end

  end

  def change
    add_column :locations, :name, :string

    Location.all.each do |location|
      location.update_attribute(:name, location.build_name)
    end
  end
end
