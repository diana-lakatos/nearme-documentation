# frozen_string_literal: true
class LongtailApi
  def initialize(endpoint:, page_slug:, campaigns: [])
    @page = Page.where(slug: page_slug,
                       theme_id: PlatformContext.current.theme.id)
                .first_or_create!(path: page_slug.humanize, content: generic_page_content)
    @campaigns = campaigns
    @endpoint = endpoint
  end

  def parse!
    with_cleanup do
      @campaigns.each do |campaign|
        parse_keyword_list(LongtailApi::KeywordListIterator.new(@endpoint, campaign: campaign))
      end
    end
  end

  def persist(keyword)
    puts "Persisting keyword: #{keyword.slug}"
    data_source_content = main_data_source.data_source_contents.where(external_id: keyword.id).first_or_create!
    data_source_content.externally_created_at = nil
    data_source_content.json_content = LongtailApi::KeywordBodyDecorator.decorate(keyword.body)
    data_source_content.mark_for_deletion = false
    data_source_content.save!
    @page.page_data_source_contents.where(data_source_content: data_source_content,
                                          slug: keyword.path).first_or_create!
  end

  def parse_keyword_list(keyword_list)
    while (keyword_data = keyword_list.next).present?
      persist(LongtailApi::Keyword.new(endpoint: @endpoint, data: keyword_data, campaign: keyword_list.campaign))
    end
  end

  def main_data_source
    @main_data_source ||= @page.data_sources.where(type: 'DataSource::CustomSource', label: @page.slug).first_or_create!
  end

  def generic_page_content
    File.read(Rails.root.join('lib', 'longtail_api', 'generic_template.html.liquid'))
  end

  def with_cleanup
    puts "Marking #{main_data_source.data_source_contents.update_all(mark_for_deletion: true)} for destruction"
    yield
    puts "Removing non parsed #{main_data_source.data_source_contents.where(mark_for_deletion: true).destroy_all} keywords"
  end
end
