module RobotsTxtService
  NEARME_SUBDOMAIN_REGEX = /^(?!www).*\.near-me.com$/

  module_function

  def content_for(domain)
    if domain.uploaded_robots_txt.file.present?
      robots_txt = domain.uploaded_robots_txt.file.read
    else
      sitemap_url = domain.url + '/sitemap.xml'
      robots_txt = []

      robots_txt << 'User-Agent: *'

      if nearme_subdomain?(domain)
        robots_txt << 'Disallow: /'
      else
        robots_txt << 'Disallow: /locations/*/host'
        robots_txt << 'Disallow: /locations/*/networking'
        robots_txt << 'Disallow: /locations/populate_address_components'
        robots_txt << 'Disallow: /listings/*/reservations'
        robots_txt << 'Disallow: /auth'
        robots_txt << 'Disallow: /search/show'
        robots_txt << 'Disallow: /authentications'
        robots_txt << 'Disallow: /v1'
        robots_txt << 'Disallow: /api'
        robots_txt << 'Disallow: /widgets'
        robots_txt << "Sitemap: #{sitemap_url}"
      end

      robots_txt = robots_txt.join("\n")
    end

    robots_txt
  end

  def nearme_subdomain?(domain)
    domain.name.match(RobotsTxtService::NEARME_SUBDOMAIN_REGEX).present?
  end
end
