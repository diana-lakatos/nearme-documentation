class RelNoFollowAdder
  def initialize(options = {})
    @skip_domains = options.delete(:skip_domains).presence || []
  end

  def modify(html_content)
    html_fragment = Nokogiri::HTML.fragment(html_content)
    html_fragment.css('a').each do |a|
      if is_link?(a) && is_not_relative_link?(a) && should_not_be_skipped?(a)
        rels = a['rel'].blank? ? [] : a['rel'].split(' ')
        rels << 'nofollow'
        a['rel'] = rels.uniq.join(' ')
      end
    end
    html_fragment.to_html
  end

  private

  def is_link?(a)
    a['href'] && !a['href'].include?('mailto:')
  end

  def should_be_skipped?(a)
    @skip_domains.any? { |skip_domain| a['href'].include?(skip_domain) }
  end

  def is_relative_link?(a)
    ['/', '?', '#'].find { |char| char == a['href'][0] }.present?
  end

  def is_not_relative_link?(a)
    !is_relative_link?(a)
  end

  def should_not_be_skipped?(a)
    !should_be_skipped?(a)
  end
end
