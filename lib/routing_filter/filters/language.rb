#   incoming url: /fr/products
#   filtered url: /products
#   params:       params[:language] = 'fr'
#
#   Usage:
#
#   products_path(language: 'cs')
#   url_for(:products, language: 'cs')


class Language < RoutingFilter::Filter
  @@include_default_locale = false
  cattr_writer :include_default_locale

  class << self
    def include_default_locale?
      @@include_default_locale
    end
  end

  attr_reader :exclude

  def initialize(*args)
    super
    @exclude = options[:exclude]
  end

  def around_recognize(path, env, &block)
    locale = extract_segment!(Locale::DOMAIN_PATTERN, path)
    yield.tap do |params| # invoke the given block (calls more filters and finally routing)
      params[:language] = locale if locale # set recognized locale to the resulting params hash
    end
  end

  # This method is for generating urls or paths, aka: url_for, link_to, etc
  def around_generate(*args, &block)
    params = args.extract_options! # this is because we might get a call like forum_topics_path(forum, topic, :language => :en)

    locale = params.delete(:language) # extract the passed :language option
    locale = I18n.locale if locale.nil? # default to I18n.locale when locale is nil (could also be false)

    args << params

    yield.tap do |result|
      url = result.is_a?(Array) ? result.first : result
      unless excluded?(url)
        prepend_segment!(result, locale) if prepend_locale?(locale) && default_locale.present?
      end
    end
  end

  protected

  def default_locale?(locale)
    locale && locale.to_sym == default_locale
  end

  def default_locale
    PlatformContext.current.try(:instance).try(:primary_locale)
  end

  def prepend_locale?(locale)
    locale && (self.class.include_default_locale? || !default_locale?(locale))
  end

  def excluded?(url)
    case exclude
    when Regexp
      url =~ exclude
    when Proc
      exclude.call(url)
    end
  end
end
