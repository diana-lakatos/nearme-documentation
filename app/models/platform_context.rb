# frozen_string_literal: true
# Class responsible for encapsulating multi-tenancy logic.
#
# PlatformContext for normal requests is set based on current domain. Information about current platform
# is accessible via class method current(). It is thread-safe, as long as we make sure the context is cleared
# between requests. For jobs invoked in background, we pass platform_context_detail [ class and id ], which allows us
# to retreive the context. We also have to make sure the context is set for each job [ nil is valid, so if we don't need context
# in certain job, we have to set it nil! ]. In some parts of the app, we have to overwrite default platform context. For example for
# admin, we don't care on which domain we are - we are admins and we should have access to everything. We can achieve this by
# manually set PlatformContext.current to nil via current= class method [ PlatformContext.current = nil ].
#
# PlatformContext is mainly used to display the right theme and text in UI, emails, and to ensure proper scoping [ i.e. if we have
# two instances, desksnear.me and boatsnear.you, we don't want to display any boats on desksnear.me, and we don't want to display
# and desks at boatsnear.you.
#
# To ensure proper scoping, there are two helper modules, which are added to any ActiveRecord classes during initializations.
# These are PlatformContext::ForeignKeysAssigner and PlatformContext::DefaultScope. The first one ensures that db columns with foreign
# keys to platform_context models [ like instance, partner, company ] are properly set. The second one ensures we retreive from db
# only records that belong to current platform context. See these classes at app/models/platform_context/ for more information.

class PlatformContext
  DEFAULT_REDIRECT_CODE = 302
  NEAR_ME_REDIRECT_URL = 'http://near-me.com/?domain_not_valid=true'
  @@instance_view_cache_key = {}

  attr_reader :domain, :platform_context_detail, :instance, :theme, :custom_theme, :domain,
              :white_label_company, :partner, :request_host, :blog_instance

  class_attribute :root_secured
  self.root_secured = Rails.application.config.root_secured

  def self.current
    Thread.current[:platform_context]
  end

  def self.current=(platform_context)
    Thread.current[:platform_context] = platform_context
    after_setting_current_callback(platform_context) if platform_context.present?
  end

  def self.after_setting_current_callback(platform_context)
    return unless platform_context.instance
    ActiveRecord::Base.establish_connection(platform_context.instance.db_connection_string) if platform_context.instance.db_connection_string.present?
    I18N_DNM_BACKEND.set_instance(platform_context.instance) if defined? I18N_DNM_BACKEND
    I18n.locale = platform_context.instance.primary_locale
    CacheExpiration.update_memory_cache
    NewRelic::Agent.add_custom_attributes(instance_id: platform_context.instance.id)
    set_es_mappings
  end

  def self.set_es_mappings
    Transactable.set_es_mapping
    User.set_es_mapping
  end

  def self.get_instance_view_cache_key(instance_id)
    InstanceView.where(instance_id: instance_id).group(:instance_id).pluck('count(*), max(updated_at)').join('-')
  end

  def self.scope_to_instance
    Thread.current[:force_scope_to_instance] = true
  end

  def self.scoped_to_instance?
    Thread.current[:force_scope_to_instance]
  end

  def self.clear_current
    Thread.current[:platform_context] = nil
    Thread.current[:force_scope_to_instance] = nil
  end

  def initialize(object = nil)
    case object
    when String
      initialize_with_request_host(object)
    when Partner
      initialize_with_partner(object)
    when Company
      initialize_with_company(object)
    when Instance
      initialize_with_instance(object)
    else
      raise "Can't initialize PlatformContext with object of class #{object.class}"
    end
  end

  def fetch_secured_domain
    Rails.cache.fetch("secured_domains_for_#{@request_host}_#{@instance.cache_key}") do
      result = nil

      result = @instance.domains.secured.where_hostname(@request_host) unless @request_host.blank?

      result ||= @instance.domains.secured.first

      result ||= @instance.domains.first if Rails.env.development? || Rails.env.test?

      result
    end
  end

  def secured_constraint
    if @secure_domain ||= fetch_secured_domain
      { host: @secure_domain.name, protocol: 'https', only_path: false }
    else
      if PlatformContext.current.instance.id == Instance.first.id
        { host: Rails.application.routes.default_url_options[:host], protocol: 'https', only_path: false }
      else
        raise NotImplementedError, "Marketplace '#{instance.name}' has not configured secured domain"
      end
    end
  end

  def secured?
    root_secured? || @domain.try(:secured?)
  end

  def require_ssl?
    Rails.application.config.secure_app && secured?
  end

  def root_secured?
    self.class.root_secured
  end

  def initialize_with_request_host(request_host)
    @request_host = remove_port_from_hostname(request_host)
    initialize_with_domain(fetch_domain)
  end

  def initialize_with_domain(domain)
    if is_root_domain?
      initialize_with_instance(Instance.first)
    else
      if domain.present? && domain.white_label_enabled? && domain.target.present?
        @domain = domain
        if @domain.white_label_company?
          initialize_with_company(@domain.target)
        elsif @domain.instance?
          initialize_with_instance(@domain.target)
        elsif @domain.partner?
          initialize_with_partner(@domain.target)
        end
      end
    end
    self
  end

  def initialize_with_partner(partner)
    @partner = partner
    @platform_context_detail = @partner
    @instance = @partner.instance
    @theme = @partner.theme.presence
    @custom_theme = @partner.try(:custom_theme)
    @domain ||= @partner.domain
    self
  end

  def initialize_with_company(company)
    if company.white_label_enabled
      @white_label_company = company
      @platform_context_detail = @white_label_company
      @instance = company.instance
      @theme = company.theme
      @custom_theme = company.try(:custom_theme)
      @domain ||= company.domain
    else
      if company.partner.present?
        initialize_with_partner(company.partner)
      else
        initialize_with_instance(company.instance)
      end
    end
    self
  end

  def rules
    return [] unless @domain
    @rules ||= @domain.reverse_proxies.where(environment: Rails.env)
  end

  def rack_rules
    @rack_rules ||= rules.map { |rp| RackReverseProxy::Rule.new(rp.path, rp.destination_domain) }
  end

  def initialize_with_instance(instance)
    @instance = instance
    @platform_context_detail = @instance
    @theme = @instance.try(:theme)
    @custom_theme = @instance.try(:custom_theme) if CustomTheme.table_exists?
    @domain ||= @instance.try(:default_domain)
    self
  end

  def white_label_company_user?(user)
    return true  if white_label_company.nil?
    return false if user.nil?
    user.companies_metadata.try(:include?, white_label_company.id)
  end

  def decorate
    @decorator ||= PlatformContextDecorator.new(self)
  end

  def should_redirect?
    return false if is_root_domain?
    return true unless @domain
    return true if @domain.redirect?
    @domain.name != @request_host
  end

  def redirect_url(path = '')
    return NEAR_ME_REDIRECT_URL unless @domain
    "#{(@domain.redirect? ? @domain.redirect_to : @domain.url)}#{path}"
  end

  def redirect_code
    return DEFAULT_REDIRECT_CODE unless @domain
    return DEFAULT_REDIRECT_CODE if @domain.redirect_code.blank?
    @domain.redirect_code
  end

  def to_h
    { request_host: @request_host }.merge(
      Hash[instance_variables
           .reject { |iv| iv.to_s == '@request_host' || iv.to_s == '@decorator' }
           .map { |iv| iv.to_s.delete('@') }
           .map { |iv| ["#{iv}_id", send(iv).try(:id)] }]
    )
  end

  def is_root_domain?
    root_domains = ['0\.0\.0\.0', 'localhost', 'near-me.com', 'setup.near-me.com', 'api\.desksnear\.me', '127\.0\.0\.1']
    root_domains += ['test\.host', '127\.0\.0\.1', 'example\.org', 'www.example\.com'] if Rails.env.test?
    @request_host =~ Regexp.new("^(#{root_domains.join('|')})$", true)
  end

  def overwrite_custom_theme(user)
    return false if @custom_theme.try(:in_use_for_instance_admins?)
    return false if user.nil?
    return false unless user.metadata[@instance.id.to_s].try(:keys).try(:include?, 'instance_admins_metadata') || user.admin?
    @custom_theme = @platform_context_detail.custom_theme_for_instance_admins if @platform_context_detail.try(:custom_theme_for_instance_admins).present?
  end

  def photo_upload_version_dimensions(version, uploader)
    @photo_upload_versions_fetcher ||= PhotoUploadVersionFetcher.new
    @photo_upload_versions_fetcher.dimensions(version, uploader)
  end

  def multiple_languages?
    return false if instance.nil?
    @multiple_language ||= instance.available_locales.many?
  end

  def url_locale
    multiple_languages? ? I18n.locale : nil
  end

  private

  def fetch_domain
    Rails.cache.fetch("domains_cache_#{@request_host}") do
      Domain.where_hostname(@request_host)
    end
  end

  def remove_port_from_hostname(hostname)
    hostname.split(':').first
  end
end
