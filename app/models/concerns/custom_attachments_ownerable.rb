# frozen_string_literal: true
module CustomAttachmentsOwnerable
  extend ActiveSupport::Concern
  included do
    has_many :custom_attachments, as: :owner

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to populate inputs
    def custom_attachments_open_struct
      nil
    end

    def default_custom_attachments_open_struct
      hash = {}
      custom_attribute_target.custom_attributes.where(attribute_type: 'file').pluck(:id, :name).each do |id, name|
        hash[name] = custom_attachments.detect { |ci| ci.custom_attribute_id == id }
      end
      OpenStruct.new(hash)
    end

    # FIXME: nead a cleaner solution - for now it's used by Form Object
    # to sync model with form after validation passes
    def custom_attachments_open_struct=(open_struct)
      open_struct.to_h.each do |ca_id, ci|
        next if ci.nil?
        custom_attachment = if ci.id.present? && ci.owner.blank?
                              CustomAttachment.where(id: ci.id, owner_type: nil, owner_id: nil, uploader_id: nil).first
                            elsif ci.id.blank? && ci.owner.blank?
                              CustomAttachment.where(custom_attribute_id: ca_id.to_s, owner_type: nil, owner_id: nil, uploader_id: nil, created_at: ci.created_at, file: ci.read_attribute(:file)).first
        end
        custom_attachments << custom_attachment if custom_attachment.present?
      end
      custom_attachments
    end
  end
end
