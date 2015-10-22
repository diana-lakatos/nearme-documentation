class SitemapGeneratorDomainJob < Job
  include Job::LongRunning

  def after_initialize(domain_id)
    @domain = Domain.find(domain_id)
  end

  def perform
    puts "  => Generating sitemap for #{@domain.name}"
    sitemap_xml = SitemapService::Generator.for_domain(@domain.id)
    SitemapService.save_changes!(@domain, sitemap_xml)
  end
end
