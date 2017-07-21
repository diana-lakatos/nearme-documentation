class CustomModelTypeLinking < ActiveRecord::Base
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :custom_model_type, touch: true
  belongs_to :linkable, polymorphic: true, touch: true
  belongs_to :transactable_type, -> { joins(:custom_model_type_linkings).where(custom_model_type_linkings: { linkable_type: 'TransactableType' }) }, foreign_key: 'linkable_id'
  belongs_to :project_type, -> { where(custom_model_type_linkings: { linkable_type: 'ProjectType' }) }, foreign_key: 'linkable_id'
  belongs_to :instance_profile_type, -> { where(custom_model_type_linkings: { linkable_type: 'InstanceProfileType' }) }, foreign_key: 'linkable_id'
  belongs_to :reservation_type, -> { where(custom_model_type_linkings: { linkable_type: 'ReservationType' }) }, foreign_key: 'linkable_id'
end
