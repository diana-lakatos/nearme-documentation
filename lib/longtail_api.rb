# frozen_string_literal: true
class LongtailApi
  TOO_MANY_ATTEMPTS_ERROR = 'Too Many Attempts.'
  def initialize(token:, host:, page_slug:)
    @page = Page.where(slug: page_slug,
                       theme_id: PlatformContext.current.theme.id)
                .first_or_create!(path: page_slug.humanize)
    @token = token
    @host = host
  end

  def parse_keywords!(url = nil)
    url ||= "#{@host}/keywords/seo"
    keywords = list_of_keywords(url)
    keywords['data'].each do |keyword|
      parse_keyword(keyword)
    end
    parse_keywords!(page, token, keywords['links']['next']) if keywords['links']['next'].present?
  end

  def parse_keyword(keyword)
    parsed_body = data_for_keyword(keyword)
    return false if parsed_body.nil?
    parsed_body = LongtailApi::ParsedBodyDecorator.decorate(parsed_body)
    @page.page_data_source_contents.where(data_source_content: create_data_source_content_for_keyword(keyword: keyword,
                                                                                                      parsed_body: parsed_body)
                                                                                                      .id,
                                          slug: keyword['attributes']['url'][1..-1]).first_or_create!
  end

  def create_data_source_content_for_keyword(keyword:, parsed_body:)
    data_source_content = main_data_source.data_source_contents.where(external_id: keyword['id']).first_or_create!
    data_source_content.external_id = keyword['id']
    data_source_content.externally_created_at = nil
    data_source_content.json_content = parsed_body
    data_source_content.save!
    data_source_content
  end

  def main_data_source
    @main_data_source ||= @page.data_sources.where(type: 'DataSource::CustomSource', label: @page.slug).first_or_create!
  end

  def list_of_keywords(url)
    JSON.parse(call_api(url))
  end

  def data_for_keyword(keyword)
    response = call_api("#{@host}/search/seo/#{keyword['attributes']['slug']}")
    while response == TOO_MANY_ATTEMPTS_ERROR
      sleep(5)
      response = call_api("#{@host}/search/seo/#{keyword['attributes']['slug']}")
    end
    parse_response(response)
  end

  def call_api(host)
    url = URI.parse(host)
    http = Net::HTTP.new(url.host, url.port)
    req = Net::HTTP::Get.new(url)
    req.add_field('Authorization', "Bearer #{@token}")
    response = http.request(req)
    response.body
  end

  def parse_response(response)
    JSON.parse(response) if response =~ /^{"data"/
  end

  def generic_page_content
    File.read(Rails.root.join('lib', 'longtail_api', 'generic_template.html.liquid'))
  end
end
