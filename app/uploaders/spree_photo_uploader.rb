# encoding: utf-8
class SpreePhotoUploader < PhotoUploader
  after :store, :remove_attachment

  def remove_attachment(file)
    model.attachment.destroy
  end
end
