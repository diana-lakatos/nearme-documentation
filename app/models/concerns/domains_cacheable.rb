module DomainsCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_domains_cache

    def clear_domains_cache
      domains_to_expire = []
      domains_to_expire += Array(self.domain) if respond_to?(:domain)
      domains_to_expire += self.domains if respond_to?(:domains)
      domains_to_expire += Array(self.instance.try(:domains)) if respond_to?(:instance)
      domains_to_expire += Array(self.owner.try(:domains)) if respond_to?(:owner) && self.owner.is_a?(Instance)
      domains_to_expire.compact.uniq.each(&:clear_cache)
    end

  end
end
