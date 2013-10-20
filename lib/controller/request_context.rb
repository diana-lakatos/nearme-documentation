class Controller::RequestContext
  attr_reader :domain, :instance, :theme, :domain, :white_label_company, :partner
  
  delegate :contact_email, :tagline, :support_url, :blog_url, :twitter_url, :facebook_url, :address,
    :phone_number, :site_name, :description, :support_email, :compiled_stylesheet, :meta_title, :to => :theme
  delegate :bookable_noun, :name, :pages, :is_desksnearme?, :to => :instance

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

  def to_liquid
    RequestContextDrop.new(self)
  end

  def compiled_stylesheet_url
    compiled_stylesheet.present? ? compiled_stylesheet.url : nil
  end

  def white_label_company_user?(user)
    white_label_company.nil? || user.try(:companies).try(:include?, white_label_company)
  end

  private

  def fetch_domain(request_host)
    @domain ||= Domain.where(:name => request_host.try(:gsub, /^www\./, "")).first
  end
  
end
