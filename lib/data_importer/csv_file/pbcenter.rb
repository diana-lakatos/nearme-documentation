require 'csv'

class DataImporter::CsvFile::Pbcenter < DataImporter::CsvFile

  attr_accessor :hour_parser

  def user_attributes
    {
      :email => @current_row[9].downcase,
      :name => @current_row[3]
    }
  end

  def company_attributes
    {
      :name => @current_row[3],
      :email => @current_row[9].downcase,
      :description => @current_row[12],
      :external_id => @current_row[1]
    }
  end

  def location_attributes
    {
      :address => ([@current_row[4], @current_row[5], @current_row[6], @current_row[7], @current_row[8]]*", "),
      :email => @current_row[9].downcase,
      :phone => @current_row[10],
      :description => @current_row[12],
      :special_notes => (@current_row[13].to_s + "\n" + @current_row[14].to_s).strip,
      :availability_template_attributes => parse_availability_rules(@current_row[11]),
      :amenities => provided_amenities.compact.uniq
    }
  end

  def address_attributes
    {
      :address => ([@current_row[4], @current_row[5], @current_row[6], @current_row[7], @current_row[8]]*", "),
      :formatted_address => ([@current_row[4], @current_row[5], @current_row[6], @current_row[7], @current_row[8]]*", "),
      :address2 => @current_row[5],
      :city => @current_row[6],
      :state => @current_row[7],
      :postcode => @current_row[8]
    }

  end

  def provided_amenities
    (22..52).inject([]) do |arr, cell_number|
        arr.tap { |a| a << amenities[cell_number-22] unless @current_row[cell_number].blank? }
    end
  end

  def listing_attributes
    {
      :external_id => @current_row[0],
      :name => @current_row[15],
      :description => (@current_row[17].blank? ? location_attributes[:description] : @current_row[17]),
      :quantity => @current_row[18],
      :hourly_price_cents => (@current_row[20].to_i * 100),
      :daily_price_cents => (@current_row[21].to_i * 100),
      :availability_template_attributes => parse_availability_rules(@current_row[16])
    }
  end

  def photo_attributes
    {
    }
  end

  def parse_availability_rules(cell)
    availability_hash = parse_availability_string(cell)
    availability_hash[:days] = (1..5).to_a
    arr.tap { |a| a <<  availability_hash.clone }
  end


  def parse_availability_string(availability_string)
    open_close_array = availability_string.split('-')
    open_array = open_close_array[0].split(':')
    close_array = open_close_array[1].split(':')
    {
      availability_rules_attributes: {
        :open_hour => open_array[0],
        :open_minute => open_array[1].to_i,
        :close_hour => close_array[0].to_i + 12,
        :close_minute => close_array[1].to_i
      }
    }
  end

  def amenities
    @amenities ||= [
      {"Admin Services" => "Administrative Assistant"},
      {"Catering" => "Catering"},
      {"Coffee & Tea Service" => "Coffee/Tea"},
      {"Conference Calling" => "Videoconferencing Facilities"},
      {"Copies (B/W)" => "Copier"},
      {"Copies (Color)" => "Copier"},
      {"Faxes Received" => "Fax"},
      {"Fax Out - First Page" => "Fax"},
      {"Fax Out -After 1st Page" => "Fax"},
      {"LCD Projector by Hour" => "Projector"},
      {"LCD Projector - Full Day" => "Projector"},
      {"Phone Usage" => "Telephone"},
      {"Polycom (Speaker Phone)" => "Telephone"},
      {"Printing (B/W)" => "Printer"},
      {"Printing (Color)" => "Printer"},
      {"Scanning" => "Scanner"},
      {"Video Conferencing (Point to Point)" => "Videoconferencing Facilities"},
      {"Flat Screen TV" => "Television"},
      {"DVD Player" => "Television" },
      {"Exterior" => "Yard Area"},
      {"Flat Screen TV" => "Television"},
      {"Flipchart"  => nil},
      {"Free Parking" => "Parking"},
      {"Interior" => "Lounge Area"},
      {"Internet Connection (Wired)" => "Internet Access"},
      {"Built-in Projector Screen" => "Projector"},
      {"TV" => "Television"},
      {"VCR/VHS player" => "Television"},
      {"Water Service" => nil},
      {"WiFi-Wireless Internet Connection" => "Wi-Fi"},
      {"Writing/White Board" => "Whiteboard"}
    ].map { |pair| pair.map { |k, v| v } }.flatten
  end

  def download_photos_from_dropbox
    # get all images for given company that are in dropbox, find photo that best matches object.name and download it
    files_with_info = DROPBOX.get_files_for_path(File.join("PBCenter", @company.external_id)).inject({}) do |files, file|
      if file.mime_type.try(:include?, 'image')
        file_name = File.basename(file.path)
        files[file_name] = {:remote_image_url => file.direct_url.url, :content_type => file.mime_type}
      end
      files
    end
    if !files_with_info.empty?
      listings = @company.locations.map { |l| l.listings }.flatten.reject { |listing| listing.photos.count > 0 }
      listing_name_file_name_pairs = StringMatcher.new(listings.map(&:name), files_with_info.keys).create_pairs
      listings.each do |listing|
        if listing_name_file_name_pairs[listing.name]
          listing_name_file_name_pairs.delete(listing.name).each do |matching_photo_name|
            listing.photos.create do |p|
              direct_url = files_with_info[matching_photo_name]
              p.remote_image_url = direct_url[:remote_image_url]
            end
          end
        end
      end
    end
  end

end

