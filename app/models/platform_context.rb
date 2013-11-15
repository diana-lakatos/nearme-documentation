class PlatformContext
  attr_reader :domain, :instance, :theme, :domain, :white_label_company, :partner, :request_host
  
  def initialize(request_host = '')
    @request_host = remove_port_from_hostname(request_host.try(:gsub, /^www\./, ""))
    fetch_domain
    if @domain && @domain.white_label_enabled?
      if @domain.white_label_company?
        @white_label_company = @domain.target
        @instance = @white_label_company.instance
        @theme = @domain.target.theme
      elsif @domain.instance?
        @instance = @domain.target
        @theme = @instance.theme
      elsif @domain.partner?
        @partner = @domain.target
        @instance = @partner.instance 
        @theme = @partner.theme.presence
      end
    else
      @instance = Instance.default_instance
      @theme = @instance.theme
    end
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

  private

  def fetch_domain
    @domain ||= Domain.where(:name => @request_host).first
  end

  def is_root_domain?
    root_domains = [Regexp.escape(remove_port_from_hostname(Rails.application.routes.default_url_options[:host])), '0\.0\.0\.0']
    root_domains += ['test\.host', '127\.0\.0\.1', 'example\.org'] if Rails.env.test?
    @request_host =~ Regexp.new("^(#{root_domains.join('|')})$", true)
  end

  def remove_port_from_hostname(hostname)
    hostname.split(':').first
  end
  
end
