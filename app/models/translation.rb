class Translation < ActiveRecord::Base

  belongs_to :instance

  scope :defaults_for, lambda { |locale| where('locale = ? AND instance_id IS NULL', locale) }
  scope :for_instance, lambda { |instance_id| where('instance_id = ?', instance_id) }
  scope :defaults, -> { where('instance_id is null') }
  scope :updated_after, lambda { |updated_at| where('updated_at > ?', updated_at) }

end
