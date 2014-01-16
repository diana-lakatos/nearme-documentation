class PlatformContext
  attr_reader :domain, :platform_context_detail, :instance, :theme, :domain, :white_label_company, :partner, :request_host

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
    @theme = @partner.theme.presence
    @domain ||= @partner.domain
    self
  end

  def initialize_with_company(company)
    if company.white_label_enabled
      @white_label_company = company
      @platform_context_detail = @white_label_company
      @instance = company.instance
      @theme = company.theme
      @domain ||= company.domain
    else
      initialize_with_instance(company.instance)
    end
    self
  end

  def initialize_with_instance(instance)
    @instance = instance
    @platform_context_detail = @instance
    @theme = @instance.theme
    # the reason why we don't want default instance to have domain is that currently it has assigned only one domain as a hack - api.desksnear.me and 
    # our urls in mailers will be wrong
    @domain ||= @instance.domains.try(:first) unless @instance.is_desksnearme?
    self
  end

  def white_label_company_user?(user)
    white_label_company.nil? || user.try(:companies).try(:include?, white_label_company)
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
           reject{|iv| iv.to_s == '@request_host'}.
           map{|iv| iv.to_s.gsub('@', '')}.
           map{|iv| ["#{iv}_id", send(iv).try(:id)]}]
    )
  end

  private

  def fetch_domain
    Domain.where(:name => @request_host).first
  end

  def is_root_domain?
    root_domains = [Regexp.escape(remove_port_from_hostname(Rails.application.routes.default_url_options[:host])), '0\.0\.0\.0', 'api\.desksnear\.me']
    root_domains += ['test\.host', '127\.0\.0\.1', 'example\.org'] if Rails.env.test?
    @request_host =~ Regexp.new("^(#{root_domains.join('|')})$", true)
  end

  def remove_port_from_hostname(hostname)
    hostname.split(':').first
  end

end
