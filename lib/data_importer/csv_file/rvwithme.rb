require 'csv'

class DataImporter::CsvFile::Rvwithme < DataImporter::CsvFile
  def company_attributes
    {
      name: get_company_name(@current_row[7], @current_row[6]),
      email: @current_row[6],
      external_id: @current_row[1],
      website: @current_row[7]
    }
  end

  def location_attributes
    {
      address: [@current_row[1], @current_row[2], @current_row[3]].join(', '),
      email: @current_row[6].downcase,
      phone: @current_row[4]
    }
  end

  def address_attributes
    {
      address: [@current_row[1], @current_row[2], @current_row[3]].join(', '),
      suburb: @current_row[2],
      postcode: @current_row[3]
    }.tap { |arr| arr[:formatted_address] = arr[:address] }
  end

  def listing_attributes
    {
      external_id: @current_row[0],
      name: @current_row[0],
      url: @currnt_row[8]
    }
  end

  def send_invitation
    true
  end
end
