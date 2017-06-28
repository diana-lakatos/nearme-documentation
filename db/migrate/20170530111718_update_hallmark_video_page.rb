# frozen_string_literal: true
class UpdateHallmarkVideoPage < ActiveRecord::Migration
  def up
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        pages = i.pages.where(path: 'Video')

        pages.each do |page|
          content = page.content.gsub('class="slider-a videos"', 'class="slider-a slider-4-cols videos"')
          content.gsub!('<a href="https:', '<a data-slider-thumbnail href="https:')
          page.update!(content: content)
        end
      end
    end
  end

  def down
    Instance.transaction do
      Instances::InstanceFinder.get(:hallmark).each do |i|
        i.set_context!

        pages = i.pages.where(path: 'Video')

        pages.each do |page|
          content = page.content.gsub('class="slider-a slider-4-cols videos"', 'class="slider-a videos"')
          content.gsub!('data-slider-thumbnail ', '')
          page.update!(content: content)
        end
      end
    end
  end
end
