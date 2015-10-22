class SitemapService::Generator
  cattr_accessor :nodes, :xml

  def initialize(instance)
    instance.domains.pluck(:id).each do |domain_id|
      self.class.for_domain(domain_id)
    end
  end

  def self.for_domain(domain_id)
    @domain = Domain.find(domain_id)
    @base_url = @domain.url

    PlatformContext.current = PlatformContext.new(@domain.target)

    self.nodes = []

    self.xml = SitemapService.sitemap_xml_opening

    with_comment(SitemapService::Node::StaticNode.comment_mark) do
      root_path = SitemapService::Node::StaticNode.new(@base_url, "/").to_xml
      self.nodes.push(root_path)
    end

    with_comment(SitemapService::Node::PageNode.comment_mark) do
      Page.all.each do |page|
        page_node = SitemapService::Node::PageNode.new(@base_url, page).to_xml
        self.nodes.push(page_node)
      end
    end

    with_comment(SitemapService::Node::TransactableNode.comment_mark) do
      Transactable.visible.group_by { |t| t.location_id }.each do |location_id, transactables|
        transactables.each do |transactable|
          transactable_node = SitemapService::Node::TransactableNode.new(@base_url, transactable).to_xml
          self.nodes.push(transactable_node)
        end
      end
    end

    with_comment(SitemapService::Node::ProductNode.comment_mark) do
      Spree::Product.all.approved.not_draft.each do |product|
        product_node = SitemapService::Node::ProductNode.new(@base_url, product).to_xml
        self.nodes.push(product_node)
      end
    end

    self.xml += self.nodes.join

    self.xml += SitemapService.sitemap_xml_closing
    self.xml = Nokogiri::XML(self.xml.squish, nil, Encoding.default_external.name)
  end

  def self.with_comment(comment, &block)
    self.nodes.push("<!--#{comment}-->")
    block.call if block_given?
    self.nodes.push("<!--/#{comment}-->")
    comment = nil
  end
end
