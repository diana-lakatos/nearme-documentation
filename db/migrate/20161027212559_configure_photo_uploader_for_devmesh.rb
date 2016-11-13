# frozen_string_literal: true
class ConfigurePhotoUploaderForDevmesh < ActiveRecord::Migration
  def up
    # apply only for devmesh...
    instance = Instance.find_by(id: 132)
    if instance.present?
      instance.set_context!
      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  680, height: 546, version_name: 'fullscreen',
                                 photo_uploader: 'PhotoUploader')
      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  200, height: 175, version_name: 'thumb',
                                 photo_uploader: 'PhotoUploader')
      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  250, height: 200, version_name: 'medium',
                                 photo_uploader: 'PhotoUploader')
      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  600, height: 482, version_name: 'space_listing',
                                 photo_uploader: 'PhotoUploader')
      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  1200, height: 800, version_name: 'golden',
                                 photo_uploader: 'PhotoUploader')

      PhotoUploadVersion.create!(apply_transform: 'resize_to_fill',
                                 width:  250, height: 200, version_name: 'medium',
                                 photo_uploader: 'AvatarUploader')

      ScheduledUploadersRegeneration.create!(photo_uploader: 'PhotoUploader')
      RegenerateUploaderVersionsJob.perform('PhotoUploader')
      ScheduledUploadersRegeneration.create!(photo_uploader: 'AvatarUploader')
      RegenerateUploaderVersionsJob.perform('AvatarUploader')
    end
  end

  def down
  end
end
