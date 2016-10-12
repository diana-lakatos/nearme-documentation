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
      root_path = SitemapService::Node::StaticNode.new(@base_url, '/').to_xml
      nodes.push(root_path)
    end

    with_comment(SitemapService::Node::PageNode.comment_mark) do
      Page.all.each do |page|
        page_node = SitemapService::Node::PageNode.new(@base_url, page).to_xml
        nodes.push(page_node)
      end
    end

    with_comment(SitemapService::Node::TransactableNode.comment_mark) do
      Transactable.visible.group_by(&:location_id).each do |_location_id, transactables|
        transactables.each do |transactable|
          transactable_node = SitemapService::Node::TransactableNode.new(@base_url, transactable).to_xml
          nodes.push(transactable_node)
        end
      end
    end

    self.xml += nodes.join

    self.xml += SitemapService.sitemap_xml_closing
    self.xml = Nokogiri::XML(self.xml.squish, nil, Encoding.default_external.name)
  end

  def self.with_comment(comment, &block)
    nodes.push("<!--#{comment}-->")
    block.call if block_given?
    nodes.push("<!--/#{comment}-->")
    comment = nil
  end
end
