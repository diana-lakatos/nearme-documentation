class SitemapGeneratorJob < Job
  include Job::LongRunning

  def perform
    Instance.find_each do |instance|
      instance.domains.pluck(:id).each do |domain_id|
        instance.set_context!
        SitemapGeneratorDomainJob.perform(domain_id)
      end
    end
  end
end
