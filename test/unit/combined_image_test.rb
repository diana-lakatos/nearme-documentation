require 'test_helper'

class CombinedImageTest < ActiveSupport::TestCase

  should 'combine temp photos' do
    paths = []

    {'image_1' => '#ffffff', 'image_2' => '#00ff00', 'image_3' => '#FF0000'}.each do |image, color|
      image_path = "#{Rails.root}/tmp/#{image}#{rand(1000000)}.jpg"
      cmd = "convert -size 100x100 xc:'#{color}' #{image_path}"
      paths << image_path
      system(cmd)
    end

    file = CombinedImage.new(paths).file
    assert_equal 100, file.width
    assert_equal 301, file.height
  end
end
