# frozen_string_literal: true
class CustomAttachment < ActiveRecord::Base
  has_paper_trail
  acts_as_paranoid
  auto_set_platform_context
  scoped_to_platform_context

  belongs_to :owner, polymorphic: true, touch: true
  belongs_to :custom_attribute, -> { with_deleted }, class_name: 'CustomAttributes::CustomAttribute'
  belongs_to :uploader, class_name: 'User'
  belongs_to :instance

  validates :file, presence: true
  validates :owner_type, presence: true
  validates :custom_attribute, presence: true
  after_commit :set_uploader_id, on: :create

  mount_uploader :file, CustomAttachmentUploader

  skip_callback :commit, :after, :remove_file!

  def set_uploader_id
    update_column(:uploader_id,
                  case custom_attribute.target_type
                  when 'InstanceProfileType', 'TransactableType'
                    uploader_id_from_owner(owner, custom_attribute.target_type)
                  when 'CustomModelType'
                    uploader_id_from_owner(owner.customizable, owner.customizable_type)
                  else
                    raise NotImplementedError
                  end)
  end

  def uploader_id_from_owner(object, association_name)
    case association_name
    when 'InstanceProfileType', 'UserProfile'
      object.user_id
    when 'TransactableType', 'Transactable'
      object.creator_id
    else
      raise NotImplementedError, "Unknown owner: #{owner.class.name}"
    end
  end
end
