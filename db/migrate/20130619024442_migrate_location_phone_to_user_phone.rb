class MigrateLocationPhoneToUserPhone < ActiveRecord::Migration
  class Location < ActiveRecord::Base
    belongs_to :company, :class_name => 'MigrateLocationPhoneToUserPhone::Company'
    delegate :creator, :to => :company, :allow_nil => true
  end

  class User < ActiveRecord::Base
  end

  class Company < ActiveRecord::Base
    belongs_to :creator, :class_name => 'MigrateLocationPhoneToUserPhone::User'
  end

  def up
    Location.where('phone is not null and phone <> ?', "").find_each do |location|
      user = location.creator
      user.phone = location.phone
      user.save!
    end

    remove_column :locations, :phone
  end

  def down
    add_column :locations, :phone, :string

    Location.reset_column_information
    Location.find_each do |location|
      location.phone = location.creator.try(:phone)
      location.save!
    end
  end
end
