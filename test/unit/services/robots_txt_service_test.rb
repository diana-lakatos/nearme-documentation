require 'test_helper'

class RobotsTxtServiceTest < ActiveSupport::TestCase
  setup do
    @instance = Instance.first || create(:instance)
    @domain = @instance.domains.first
  end

  context '.content_for' do
    should 'use first #uploaded_robots_txt' do
      @domain.uploaded_robots_txt = fixture_file_upload('robots.txt')
      @domain.save
      assert_equal @domain.robots, File.read("#{Rails.root}/test/fixtures/robots.txt")
    end

    should 'use default robots otherwise' do
      @domain.remove_uploaded_robots_txt = true
      @domain.save
      assert_equal @domain.robots.present?, true
    end
  end

end
