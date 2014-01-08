require 'test_helper'

class PageTest < ActiveSupport::TestCase
  def setup
    @instance = FactoryGirl.create(:instance)
    Domain.create(:name => 'allowed_domain.com', :target => @instance)
  end

  context '#homepage_content' do

    setup do
      @page = Page.new(:content => example_markdown_content, :theme => @instance.theme, :path => 'Sample Page')
    end

    should 'add no follow to unknown links' do
      @page.save
      assert_equal expected_html_content, @page.html_content.strip
    end

  end


  private 

  def example_markdown_content
    "# FAQ\n*[Checking link](http://example.com)\n*[Checking link](http://allowed_domain.com/cool/path)"
  end

  def expected_html_content
    '<h1>FAQ</h1>' + "\n\n" + '<p><em><a href="http://example.com" rel="nofollow">Checking link</a>' + "\n" + '</em><a href="http://allowed_domain.com/cool/path">Checking link</a></p>'
  end
end

