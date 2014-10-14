class InstanceProfileType < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  acts_as_custom_attributes_set
  belongs_to :instance
  has_many :user_instance_profiles

end

