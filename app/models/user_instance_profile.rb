class UserInstanceProfile < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :instance_profile_type
  belongs_to :user

  has_many :reservations, through: :user
  has_many :transactables, through: :user, source: 'listings'

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  def instance_profile_type_id
    read_attribute(:instance_profile_type_id) || instance_profile_type.try(:id)
  end

end

