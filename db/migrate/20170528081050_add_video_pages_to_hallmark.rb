# frozen_string_literal: true
class AddVideoPagesToHallmark < ActiveRecord::Migration
  def up
    Page.reset_column_information
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        content = <<EOC
          {% content_for 'hero_header' %}
            <div class="wrap" style="background-image: url('https://dmtyylqvwgyxw.cloudfront.net/instances/5011/uploads/images/ckeditor/picture/data/1420/home-signed-in.jpg');">
              <div class="contain">
                <h1 class="hx">Hallmark KOC Videos</h1>
                <p>Lorem ipsum dolor sit amet</p>
              </div>
            </div>
          {% endcontent_for %}

          {% for i in (1..4) %}
          <h2>Video Category</h2>
          <div class="slider-a videos" data-slider>
            <div class="slider-a-wrap" data-slider-wrap>
              <ul data-slider-list>
                <li><a href="https://www.youtube.com/watch?v=OkgJsxHi6RY&amp;test=2">YouTube</a></li>
                <li><a href="https://vimeo.com/217499569">Vimeo</a></li>
                <li><a href="https://www.facebook.com/seen.everything/videos/1155393794565156/?permPage=1">Facebook</a></li>
                <li><a href="https://www.youtube.com/watch?v=OkgJsxHi6RY">YouTube</a></li>
                <li><a href="https://vimeo.com/217499569">Vimeo</a></li>
                <li><a href="https://www.facebook.com/seen.everything/videos/1155393794565156/?permPage=1">Facebook</a></li>
                <li><a href="https://www.youtube.com/watch?v=OkgJsxHi6RY">YouTube</a></li>
                <li><a href="https://vimeo.com/217499569">Vimeo</a></li>
                <li><a href="https://www.facebook.com/seen.everything/videos/1155393794565156/?permPage=1">Facebook</a></li>
                <li><a href="https://www.youtube.com/watch?v=OkgJsxHi6RY">YouTube</a></li>
              </ul>
            </div>
          </div>
          {% endfor %}
EOC

        page = i.pages.where(slug: 'video', path: 'Video').first_or_create!

        page.layout_name = 'community'
        page.theme = i.theme
        page.content = content
        page.save!

        page = i.pages.where(slug: 'video-staging', path: 'Video Staging').first_or_create!
        page.layout_name = 'community'
        page.theme = i.theme
        page.content = content
        page.save!
      end
    end
  end

  def down
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        i.pages.where(slug: 'video').delete_all

        i.pages.where(slug: 'video-staging').delete_all
      end
    end
  end
end
