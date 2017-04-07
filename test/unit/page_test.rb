require 'test_helper'

class PageTest < ActiveSupport::TestCase
  setup do
    @instance = FactoryGirl.create(:instance)
    Domain.create(name: 'allowed-domain.com', target: @instance)
  end

  context '#homepage_content' do
    setup do
      @page = Page.new(content: example_markdown_content, theme: @instance.theme, path: 'Sample Page')
    end

    should 'add no follow to unknown links' do
      @page.save
      assert_equal expected_html_content, @page.html_content.strip
    end

    context 'performing convertion' do
      should 'not try to convert when html content has not changed' do
        @page = Page.create(content: example_markdown_content, theme: @instance.theme, path: 'Sample Page')
        @page.expects(:convert_to_html).never
        @page.path = 'some path'
        assert @page.save
      end

      should 'try to convert when html content has not changed but it is empty' do
        @page = Page.create(content: example_markdown_content, theme: @instance.theme, path: 'Sample Page')
        @page.update_column(:html_content, nil)
        @page.expects(:convert_to_html).once
        @page.path = 'some path'
        assert @page.save
      end

      should 'convert when html content has changed' do
        @page = Page.create(content: example_markdown_content, theme: @instance.theme, path: 'Sample Page')
        @page.content = @page.content + '### Hello'
        @page.expects(:convert_to_html).once
        assert @page.save
      end
    end
  end

  should 'not convert when html content entered xxx' do
    binding.pry
    page = Page.create(content: '<p> {% content_for head %} </p>', theme: @instance.theme, path: 'Sample Page')

    assert '<p> {% content_for head %} </p>', page.html_content
  end

  context 'url slugging' do
    should 'create unique slugs per theme' do
      FactoryGirl.create(:page, theme: @instance.theme, slug: 'faq')
      assert_raises 'ActiveRecord::RecordInvalid' do
        FactoryGirl.create(:page, theme: @instance.theme, slug: 'faq')
      end
    end

    should 'allow the same slug in two different themes' do
      @instance_two = FactoryGirl.create(:instance)
      page_one = FactoryGirl.create(:page, theme: @instance.theme, slug: 'company')
      page_two = FactoryGirl.create(:page, theme: @instance_two.theme, slug: 'company')
      assert page_one.slug == 'company'
      assert page_two.slug == 'company'
    end

    should 'keep the same slug on save if the path attribute did not change' do
      page = FactoryGirl.create(:page, theme: @instance.theme)
      original_slug = page.slug
      page.save!
      assert page.slug == original_slug
    end
  end

  context '#redirect_url_in_known_domain' do
    should 'return true for relative url' do
      page = FactoryGirl.create(:page, redirect_url: '/test')
      assert page.redirect_url_in_known_domain?
    end

    should 'return true for redirect_url matching any domain' do
      domain = FactoryGirl.create(:domain)
      page = FactoryGirl.create(:page, redirect_url: "http://#{domain.name}/test")
      assert page.redirect_url_in_known_domain?
    end

    should 'return false for redirect_url not matching any domain' do
      domain = FactoryGirl.create(:domain)
      page = FactoryGirl.create(:page, redirect_url: 'https://xyz.com/test')
      refute page.redirect_url_in_known_domain?
    end
  end

  private

  def example_markdown_content
    "# FAQ\n*[Checking link](http://example.com)*\n[Checking link](http://allowed-domain.com/cool/path)"
  end

  def expected_html_content
    '<h1>FAQ</h1>' + "\n\n" + '<p><em><a href="http://example.com">Checking link</a></em>' + "\n" + '<a href="http://allowed-domain.com/cool/path">Checking link</a></p>'
  end
end
