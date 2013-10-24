class PlatformContext
  attr_reader :domain, :instance, :theme, :domain, :white_label_company, :partner
  
  def initialize(request_host = '')
    fetch_domain(request_host)
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

  private

  def fetch_domain(request_host)
    @domain ||= Domain.where(:name => request_host.try(:gsub, /^www\./, "")).first
  end
  
end
