class PlatformContextDecorator

  delegate :white_label_company, :instance, :theme, :partner, :domain, :white_label_company_user?, :to => :platform_context

  delegate :contact_email, :tagline, :support_url, :blog_url, :twitter_url, :facebook_url, :gplus_url, :address,
    :phone_number, :site_name, :description, :support_email, :compiled_stylesheet, :meta_title, :pages, :logo_image,
    :favicon_image, :homepage_content, :call_to_action, :to => :theme

  delegate :custom_stripe_public_key, :bookable_noun, :lessor, :lessee, :name, :is_desksnearme?, :to => :instance

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

  private

  def platform_context
    @platform_context
  end

end
