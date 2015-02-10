# Used in UserBlogPost only
class AuthorAvatarUploader < BaseImageUploader
  include CarrierWave::TransformableImage

  self.dimensions = {
      :thumb => { :width => 96, :height => 96 },
      :medium => { :width => 144, :height => 144 },
      :big => { :width => 279, :height => 279 },
      :large => { :width => 1280, :height => 960 }
  }

  version :thumb, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:thumb][:width], dimensions[:thumb][:height]]
  end

  version :medium, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:medium][:width], dimensions[:medium][:height]]
  end

  version :big, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:big][:width], dimensions[:big][:height]]
  end

  version :large, :from_version => :transformed do
    process :resize_to_fill => [dimensions[:large][:width], dimensions[:large][:height]]
  end
end
