class SitemapSearchEngineUpdateJob < Job
  include Job::LongRunning

  def after_initialize(sitemap_url)
    @sitemap_url = sitemap_url
  end

  def perform
    [
      "http://www.google.com/webmasters/tools/ping?sitemap=#{@sitemap_url}",
      "http://www.bing.com/ping?sitemap=#{@sitemap_url}"
    ].each do |url|
      Net::HTTP.get(URI(url))
    end
  end
end
