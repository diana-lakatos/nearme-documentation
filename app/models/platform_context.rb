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
  attr_reader :domain, :platform_context_detail, :instance_type, :instance, :theme, :domain,
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
    ActiveRecord::Base.establish_connection(platform_context.instance.db_connection_string) if platform_context.instance.db_connection_string.present?
    Transactable.clear_transactable_type_attributes_cache
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
    when nil
      initialize_with_instance(Instance.default_instance)
    else
      raise "Can't initialize PlatformContext with object of class #{object.class}"
    end
  end

  def secured_constraint
    if domain = @instance.domains.secured.first
      {host: domain.name, protocol: 'https', only_path: false}
    else
      {host: Rails.application.routes.default_url_options[:host], protocol: 'https', only_path: false}
    end
  end

  def secured?
    (is_root_domain? and root_secured?) || @domain.try(:secured?)
  end

  def root_secured?
    self.class.root_secured
  end

  def initialize_with_request_host(request_host)
    @request_host = remove_port_from_hostname(request_host.try(:gsub, /^www\./, ""))
    initialize_with_domain(fetch_domain)
  end

  def initialize_with_domain(domain)
    @domain = domain
    if @domain && @domain.white_label_enabled?
      if @domain.white_label_company?
        initialize_with_company(@domain.target)
      elsif @domain.instance?
        initialize_with_instance(@domain.target)
      elsif @domain.partner?
        initialize_with_partner(@domain.target)
      end
    else
      initialize_with_instance(Instance.default_instance)
    end
    self
  end

  def initialize_with_partner(partner)
    @partner = partner
    @platform_context_detail = @partner
    @instance = @partner.instance
    @instance_type = @instance.instance_type
    @theme = @partner.theme.presence
    @domain ||= @partner.domain
    self
  end

  def initialize_with_company(company)
    if company.white_label_enabled
      @white_label_company = company
      @platform_context_detail = @white_label_company
      @instance = company.instance
      @instance_type = @instance.instance_type
      @theme = company.theme
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

  def initialize_with_instance(instance)
    @instance = instance
    @instance_type = @instance.instance_type
    @platform_context_detail = @instance
    @theme = @instance.theme
    # the reason why we don't want default instance to have domain is that currently it has assigned only one domain as a hack - api.desksnear.me and
    # our urls in mailers will be wrong
    @domain ||= @instance.domains.try(:first) unless @instance.is_desksnearme?
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

  # Check if domain is configured
  def valid_domain?
    @domain || is_root_domain?
  end

  def to_h
    { request_host: @request_host }.merge(
      Hash[instance_variables.
           reject{|iv| iv.to_s == '@request_host' || iv.to_s == '@decorator'}.
           map{|iv| iv.to_s.gsub('@', '')}.
           map{|iv| ["#{iv}_id", send(iv).try(:id)]}]
    )
  end

  private

  def fetch_domain
    Domain.where(:name => @request_host).first
  end

  def is_root_domain?
    root_domains = [Regexp.escape(remove_port_from_hostname(Rails.application.routes.default_url_options[:host])), '0\.0\.0\.0', 'near-me.com', 'api\.desksnear\.me', '127\.0\.0\.1']
    root_domains += ['test\.host', '127\.0\.0\.1', 'example\.org'] if Rails.env.test?
    @request_host =~ Regexp.new("^(#{root_domains.join('|')})$", true)
  end

  def remove_port_from_hostname(hostname)
    hostname.split(':').first
  end

end
