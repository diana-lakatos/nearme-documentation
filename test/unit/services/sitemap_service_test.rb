require 'test_helper'

class SitemapServiceTest < ActiveSupport::TestCase
  setup do
    @page = create(:page)
    @transactable = create(:transactable)
    @product = create(:product)
    @domain = PlatformContext.current.domain
    SitemapService.stubs(:update_on_search_engines).returns(nil)
  end

  context ".content_for" do
    should 'use first #uploaded_sitemap' do
      @domain.uploaded_sitemap = fixture_file_upload('sitemap.xml')
      @domain.save
      assert_equal @domain.sitemap, File.read("#{Rails.root}/test/fixtures/sitemap.xml")
    end

    should 'use #generated_sitemap if #uploaded_sitemap fails' do
      @domain.remove_uploaded_sitemap = true
      @domain.save

      xml = SitemapService::Generator.new(PlatformContext.current.instance).xml
      SitemapService.save_changes!(@domain, xml)
      refute @domain.uploaded_sitemap.file.present?
      assert_equal xml.to_s.squish, @domain.sitemap
    end

    should 'use SitemapService::Generator if #generated_sitemap fails' do
      @domain.remove_uploaded_sitemap = true
      @domain.remove_generated_sitemap = true
      @domain.save

      refute @domain.uploaded_sitemap.file.present?
      refute @domain.generated_sitemap.file.present?
      assert_equal SitemapService::Generator.for_domain(@domain).to_s.squish, @domain.sitemap
    end
  end

  context "Generator" do
    should "respond_to class attributes" do
      assert SitemapService::Generator.respond_to?(:nodes)
      assert SitemapService::Generator.respond_to?(:xml)
    end

    context "#initialize" do
      setup do
        SitemapService::Generator.new(PlatformContext.current.instance)
        @xml = SitemapService::Generator.xml
      end

      should "populate @@xml" do
        assert_not_nil @xml
        assert_equal Nokogiri::XML::Document, @xml.class
      end

      should "contain nodes for each record" do
        # One for each record, and one for root path
        assert_node_count(@xml, "urlset url", 4)
      end

      should "contain comment marks for each class" do
        # Opening and closing comment tags
        klasses = SitemapService::Node.descendants - [SitemapService::Node::FakeNode]
        klasses.each do |node_child_klass|
          assert @xml.xpath("//comment()[contains(.,'#{node_child_klass.comment_mark}')]").first.present?
          assert @xml.xpath("//comment()[contains(.,'/#{node_child_klass.comment_mark}')]").first.present?
        end
      end
    end

    should ".for_domain" do
      domain2 = create(:domain, target_id: PlatformContext.current.instance.id)

      xml1 = SitemapService::Generator.for_domain(@domain)
      xml2 = SitemapService::Generator.for_domain(domain2)

      # We have different content for sitemaps, since the domain differs.
      assert_not_equal xml1.content, xml2.content
    end
  end

  context "Node" do
    context "Base" do
      setup do
        @timestamp = DateTime.now
        @object = OpenStruct.new(updated_at: @timestamp)
        @node = SitemapService::Node.new(@domain.url, @object)
      end

      should "be able to access instance methods" do
        assert_raise SitemapService::InvalidLocationError do
          @node.location
        end

        assert_equal @timestamp.iso8601, @node.lastmod
        assert_equal "weekly", @node.changefreq
        assert_equal "0.5", @node.priority
        assert_nil @node.image
      end

      should "#to_xml" do
        node = SitemapService::Node::FakeNode.new(@domain.url, @object)
        xml = Nokogiri::XML(node.to_xml)

        assert_node_content xml, "url loc", @domain.url + node.location
        assert_node_content xml, "url lastmod", node.lastmod
        assert_node_content xml, "url changefreq", node.changefreq
        assert_node_content xml, "url priority", node.priority
        assert_includes xml.content, node.image
      end
    end

    context "StaticNode" do
      setup do
        @static_node = SitemapService::Node::StaticNode.new(@domain.url, "/")
      end

      should "#location" do
        assert_equal "/", @static_node.location
      end

      should "#lastmod" do
        assert_nil @static_node.lastmod
      end

      should "#changefreq" do
        assert_equal "monthly", @static_node.changefreq
      end

      should "#priority" do
        assert_equal "0.5", @static_node.priority
      end
    end

    context "PageNode" do
      setup do
        @page_node = SitemapService::Node::PageNode.new(@domain.url, @page)
      end

      should "#location" do
        assert_equal url_helpers.pages_path(@page), @page_node.location
      end

      should "#lastmod" do
        assert_equal @page.updated_at.iso8601, @page_node.lastmod
      end

      should "#changefreq" do
        assert_equal "weekly", @page_node.changefreq
      end

      should "#priority" do
        assert_equal "0.5", @page_node.priority
      end
    end

    context "TransactableNode" do
      setup do
        @transactable_node = SitemapService::Node::TransactableNode.new(@domain.url, @transactable)
      end

      should "#location" do
        assert_equal @transactable.decorate.show_path, @transactable_node.location
      end

      should "#lastmod" do
        assert_equal @transactable.updated_at.iso8601, @transactable_node.lastmod
      end

      should "#changefreq" do
        assert_equal "daily", @transactable_node.changefreq
      end

      should "#priority" do
        assert_equal "0.5", @transactable_node.priority
      end
    end

    context "ProductNode" do
      setup do
        @product_node = SitemapService::Node::ProductNode.new(@domain.url, @product)
      end

      should "#location" do
        assert_equal url_helpers.product_path(@product.slug), @product_node.location
      end

      should "#lastmod" do
        assert_equal @product.updated_at.iso8601, @product_node.lastmod
      end

      should "#changefreq" do
        assert_equal "daily", @product_node.changefreq
      end

      should "#priority" do
        assert_equal "0.5", @product_node.priority
      end
    end
  end

  context "Callbacks" do
    should "after_create #create_sitemap_node" do
      5.times do
        create(:page)
        assert_nodes_between_comment(@domain, SitemapService::Node::PageNode.comment_mark, Page.count)
      end
    end

    should "after_update #update_sitemap_node" do
      5.times do
        create(:page)
        assert_nodes_between_comment(@domain, SitemapService::Node::PageNode.comment_mark, Page.count)
      end

      page = Page.last

      old_slug = page.slug
      old_path = url_helpers.pages_path(page.slug)

      assert_node_content Nokogiri::XML(@domain.sitemap), "url loc", old_path

      page.slug = "another-path"
      page.save

      assert_not_equal old_slug, page.slug

      new_path = url_helpers.pages_path(page.slug)

      assert_node_content Nokogiri::XML(@domain.sitemap), "url loc", new_path
      assert_node_absence Nokogiri::XML(@domain.sitemap), "url loc", old_path
    end

    should "after_destroy #destroy_sitemap_node" do
      pages = []
      amount = 5

      amount.times do
        pages << create(:page)
        assert_nodes_between_comment(@domain, SitemapService::Node::PageNode.comment_mark, Page.count)
      end

      pages.each do |page|
        # One node for the transactable, one for a product and another for root.
        amount = 3 + (Page.count - 1)
        page.destroy
        assert_node_count Nokogiri::XML(@domain.reload.sitemap), "url loc", amount
        assert_node_absence Nokogiri::XML(@domain.reload.sitemap), "url loc", page.slug
      end
    end
  end

  def assert_node_content(xml, node, content)
    assert xml.css("#{node}:contains('#{content}')").try(:first).present?
  end

  def assert_node_absence(xml, node, content)
    refute xml.css("#{node}:contains('#{content}')").try(:first).present?
  end

  def assert_node_count(xml, node, count)
    assert_equal xml.css(node).count, count
  end

  def assert_nodes_between_comment(domain, comment_mark, expected_count)
    xml = Nokogiri::XML(domain.sitemap)
    start_comment = xml.xpath("//comment()[contains(.,'#{comment_mark}')]").first
    current_node = start_comment.next_sibling
    count = 0
    loop do
      break if current_node.comment?
      count = count + 1 if current_node.element?
      current_node = current_node.next_sibling
    end
    assert_equal expected_count, count
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  class SitemapService::Node::FakeNode < SitemapService::Node
    def location
      "/test/"
    end

    def image
      "image.png"
    end

    def self.comment_mark
      "fake"
    end
  end
end
