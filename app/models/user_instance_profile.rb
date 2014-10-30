class UserInstanceProfile < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :instance
  belongs_to :instance_profile_type
  belongs_to :user

  has_many :reservations, -> (o) { where instance_id: o.instance_id }, through: :user
  has_many :transactables, -> (o) { where 'transactables.instance_id' => o.instance_id }, through: :user, source: 'listings'

  has_custom_attributes target_type: 'InstanceProfileType', target_id: :instance_profile_type_id

  def instance_profile_type_id
    read_attribute(:instance_profile_type_id) || instance_profile_type.try(:id)
  end

end

