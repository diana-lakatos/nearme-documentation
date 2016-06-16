module SitemapService
  class InvalidLocationError < StandardError; end

  module_function

  def content_for(domain)
    domain.uploaded_sitemap.try(:file).try(:read).presence || 
      domain.generated_sitemap.try(:file).try(:read).presence || 
      SitemapService::Generator.for_domain(domain).to_s.squish
  rescue
    new_sitemap = SitemapService::Generator.for_domain(domain).to_s.squish
    SitemapService.save_changes!(domain, new_sitemap)
    new_sitemap
  end

  def sitemap_xml_opening
    <<-XML
      <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" 
        xmlns:image="http://www.google.com/schemas/sitemap-image/1.1" 
        xmlns:video="http://www.google.com/schemas/sitemap-video/1.1">
    XML
  end

  def sitemap_xml_closing
    <<-XML
      </urlset>
    XML
  end

  def default_sitemap
    xml = []
    comments = []

    xml.push(sitemap_xml_opening)

    [
      SitemapService::Node::StaticNode,
      SitemapService::Node::PageNode,
      SitemapService::Node::TransactableNode,
      SitemapService::Node::ProductNode
    ].each do |klass|
      comments.push(klass.comment_mark)
    end

    comments.each do |comment|
      xml.push("<!--#{comment}--><!--/#{comment}-->")
    end

    xml.push(sitemap_xml_closing)

    return xml.join
  end

  def node_class_for_object(object)
    klass = if object.class.name == Spree::Product
      "SitemapService::Node::ProductNode"
    else
      "SitemapService::Node::#{object.class.name}Node"
    end

    klass.constantize
  end

  def tmp_path
    "#{Rails.root}/tmp/sitemaps"
  end

  def tmp_filename_for(domain)
    domain.id.to_s
  end

  def save_changes!(domain, sitemap_xml)
    system "mkdir", "-p", tmp_path

    tmp_file = Tempfile.new([tmp_filename_for(domain), ".xml"])
    begin
      tmp_file.write(sitemap_xml.to_s.squish)
      domain.generated_sitemap = tmp_file
      domain.save(validate: false)
      update_on_search_engines(domain)
    ensure
      tmp_file.close
      tmp_file.unlink
    end

  end

  def update_on_search_engines(domain)
    if Rails.env.production? || Rails.env.staging?
      sitemap_url = "http://#{domain.name}/sitemap.xml"
      ::SitemapSearchEngineUpdateJob.perform(sitemap_url)
    end
  end
end
