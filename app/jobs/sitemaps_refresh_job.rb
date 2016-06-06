class SitemapsRefreshJob < Job
  def after_initialize
  end

  def perform
    Instance.find_each do |instance|
      instance.set_context!

      instance.domains.find_each do |domain|
        domain.remove_generated_sitemap!
        domain.save
      end
    end
  end
end
