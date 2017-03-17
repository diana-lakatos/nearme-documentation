# frozen_string_literal: true
module DomainsCacheable
  extend ActiveSupport::Concern

  included do
    after_commit :clear_domains_cache

    def clear_domains_cache
      domains_to_expire = []
      domains_to_expire += Array(domain) if respond_to?(:domain)
      domains_to_expire += domains if respond_to?(:domains)
      domains_to_expire += Array(instance.try(:domains)) if respond_to?(:instance)
      domains_to_expire += Array(owner.try(:domains)) if respond_to?(:owner) && owner.is_a?(Instance)
      domains_to_expire.compact.uniq.each(&:clear_cache)
    end
  end
end
