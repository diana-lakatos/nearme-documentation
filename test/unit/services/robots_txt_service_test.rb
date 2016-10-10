require 'test_helper'

class RobotsTxtServiceTest < ActiveSupport::TestCase
  setup do
    @domain = PlatformContext.current.domain
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

    should 'disallow everything if near-me.com subdomain' do
      disallow_root = /^Disallow: \/$/

      @domain.name = 'something.near-me.com'
      @domain.save
      subdomain_match = (@domain.name =~ RobotsTxtService::NEARME_SUBDOMAIN_REGEX).present?
      assert subdomain_match
      assert (@domain.robots =~ disallow_root).present?

      @domain.name = 'mymarketplace.com'
      @domain.save
      no_subdomain_matches = (@domain.name =~ RobotsTxtService::NEARME_SUBDOMAIN_REGEX).present?
      refute no_subdomain_matches
      refute (@domain.robots =~ disallow_root).present?
    end
  end
end
