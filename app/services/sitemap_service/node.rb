class SitemapService::Node
  attr_accessor :xml

  def initialize(base_url, object)
    @base_url = base_url
    @object = object
  end

  def location
    raise SitemapService::InvalidLocationError.new("Please define $location in the child class.")
  end

  def lastmod
    @object.try(:updated_at).try(:iso8601)
  end

  def changefreq
    # Allowed options: always|hourly|daily|weekly|monthly|yearly|never
    "weekly"
  end

  def priority
    # We could bump a page's priority based on KPIs, e.g.:
    # how many orders this product had in the past 30 days? bookings? hits? conversions? etc.
    return "0.5"
  end

  def image
    nil
  end

  def to_xml
    self.xml = <<-XML
      <url>
    XML

    self.append_node!("loc", url_for(self.location))
    self.append_node!("lastmod", self.lastmod) if self.lastmod.present?
    self.append_node!("changefreq", self.changefreq)
    self.append_node!("priority", self.priority)
    self.append_image! if self.image.present?

    self.xml += <<-XML
      </url>
    XML

    self.xml = self.xml.squish

    return self.xml
  end

  def url_helpers
    Rails.application.routes.url_helpers
  end

  protected

  def url_for(location)
    @base_url + location
  end

  def append_node!(key, value)
    self.xml += <<-XML
      <$key>$value</$key>
    XML

    self.xml.gsub!("$key", key)
    self.xml.gsub!("$value", value)
  end

  def append_image!
    self.xml += <<-XML
      <image:image>
        <image:loc>$image</image:loc>
      </image:image>
    XML

    self.xml.gsub!("$image", self.image)
  end
end
