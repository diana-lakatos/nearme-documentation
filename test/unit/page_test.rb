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

    context 'performing convertion' do
      should 'not try to convert when html content has not changed' do
        @page = Page.create(:content => example_markdown_content, :theme => @instance.theme, :path => 'Sample Page')
        @page.expects(:convert_to_html).never
        @page.path = 'some path'
        assert @page.save
      end

      should 'try to convert when html content has not changed but it is empty' do
        @page = Page.create(:content => example_markdown_content, :theme => @instance.theme, :path => 'Sample Page')
        @page.update_column(:html_content, nil)
        @page.expects(:convert_to_html).once
        @page.path = 'some path'
        assert @page.save
      end

      should 'convert when html content has changed' do
        @page = Page.create(:content => example_markdown_content, :theme => @instance.theme, :path => 'Sample Page')
        @page.content = @page.content + '### Hello'
        @page.expects(:convert_to_html).once
        assert @page.save
      end
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

