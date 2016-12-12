class SitemapsRefreshJob < Job
  include Job::LongRunning
  def after_initialize(domain_id)
    @domain_id = domain_id
  end

  def perform
    @domain = Domain.find(@domain_id)
    @domain.remove_generated_sitemap = true
    @domain.save(validate: false)
    SitemapService.send(:save_changes!, @domain, SitemapService::Generator.for_domain(@domain).to_s.squish)
  end
end
