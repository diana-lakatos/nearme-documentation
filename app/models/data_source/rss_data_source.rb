require 'rss'

class DataSource::RssDataSource < DataSource
  def self.settings
    {
      endpoint: ''
    }
  end

  def parse!
    rss = RSS::Parser.parse(settings['endpoint'], false)
    # we want to cache, otherwise we will download just the first item
    @latest_item_pub_date = latest_item_pub_date
    rss.try(:items).try(:each) do |item|
      break if @latest_item_pub_date.present? && @latest_item_pub_date > item.pubDate
      data_source_contents.create! do |data_source_content|
        data_source_content.content = {}
        fields.reject(&:blank?).each do |field|
          data_source_content.content[field] = item.send(field)
        end
        data_source_content.externally_created_at = item.pubDate
        data_source_content.external_id = item.guid.try(:content) || item.try(:link) || item.try(:title)
      end
    end
  end
end
