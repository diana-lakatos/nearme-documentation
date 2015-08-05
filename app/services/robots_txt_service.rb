module RobotsTxtService
  module_function
  
  def content_for(domain)
    if domain.uploaded_robots_txt.file.present?
      robots_txt = domain.uploaded_robots_txt.file.read
    else
      sitemap_url = domain.url + "/sitemap.xml"
      robots_txt = []
      
      robots_txt << "User-Agent: *"
      robots_txt << "Disallow: /locations/*/host"
      robots_txt << "Disallow: /locations/*/networking"
      robots_txt << "Disallow: /locations/populate_address_components"
      robots_txt << "Disallow: /listings/*/reservations"
      robots_txt << "Disallow: /auth"
      robots_txt << "Disallow: /search/show"
      robots_txt << "Disallow: /authentications"
      robots_txt << "Disallow: /v1"
      robots_txt << "Disallow: /widgets"
      robots_txt << "Sitemap: #{sitemap_url}"

      robots_txt = robots_txt.join("\n")
    end

    return robots_txt
  end
end
