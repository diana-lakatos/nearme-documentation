class PlatformContextDecorator

  delegate :white_label_company, :instance, :theme, :partner, :domain, :white_label_company_user?, :to => :platform_context

  delegate :tagline, :support_url, :blog_url, :twitter_url, :facebook_url, :gplus_url, :address,
    :phone_number, :site_name, :description, :support_email, :compiled_stylesheet, :meta_title, :pages, :logo_image,
    :favicon_image, :homepage_content, :call_to_action, :to => :theme

  delegate :stripe_public_key, :bookable_noun, :lessor, :lessee, :name, :is_desksnearme?, :to => :instance

  def initialize(platform_context)
    @platform_context = platform_context
  end

  def compiled_stylesheet_url
    compiled_stylesheet.present? ? compiled_stylesheet.url : nil
  end

  def to_liquid
    @platform_context_drop ||= PlatformContextDrop.new(self)
  end

  def lessors
    lessor.pluralize
  end

  def lessees
    lessee.pluralize
  end

  def host
    domain.try(:name) || Rails.application.routes.default_url_options[:host] 
  end

  def build_url_for_path(path)
    raise "Argument should not contain protocol" unless path[0] == '/'
    "http://#{host}#{path}"
  end

  def support_email_for(error_code)
    if self.is_desksnearme? || !self.support_email.present?
      "support+#{error_code}@desksnear.me"
    else
      support_email_splited = self.support_email.split('@')
      support_email_splited.join("+#{error_code}@")
    end
  end

  def contact_email
    @platform_context.theme.contact_email_with_fallback
  end

  private

  def platform_context
    @platform_context
  end

end
