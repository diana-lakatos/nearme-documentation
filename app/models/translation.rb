class Translation < ActiveRecord::Base

  belongs_to :instance

  scope :defaults_for, lambda { |locale| where('locale = ? AND instance_id IS NULL', locale) }

end
