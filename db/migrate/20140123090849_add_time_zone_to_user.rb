class AddTimeZoneToUser < ActiveRecord::Migration

  class User < ActiveRecord::Base
  end

  def change
    add_column :users, :time_zone, :string, default: 'Pacific Time (US & Canada)'

    User.all.each do |user|
      user.update_column(:time_zone, 'Pacific Time (US & Canada)')
    end
  end
end
