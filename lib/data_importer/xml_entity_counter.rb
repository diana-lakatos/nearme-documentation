class DataImporter::XmlEntityCounter < DataImporter::File
  def initialize(path)
    super(path)
  end

  def all_objects_count
    @node = Nokogiri::XML(open(@path))
    @node.xpath('companies/company/locations/location').inject(0) do |sum, node|
      node.xpath('listings/listing').each do |listing_node|
        sum += 1
        sum += listing_node.xpath('photos/photo').count
      end
      sum += 1
    end
  end
end
