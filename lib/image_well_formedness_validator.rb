class ImageWellFormednessValidator < ActiveModel::Validator
  def validate(record)
    return if record.image.blank? || record.image.path.blank?

    t = MiniMagick::Tool::Identify.new
    t.args << '-format'
    t.args << '%m'
    t.args << record.image.path
    t.call
  rescue
    record.errors.add(:image, I18n.t('uploaders.image.invalid_format'))
  end
end