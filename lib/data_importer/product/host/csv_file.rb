class DataImporter::Product::Host::CsvFile < DataImporter::Product::CsvFile

  def initialize(data_upload)
    super(data_upload)
    @user = data_upload.uploader
    @company = @user.companies.first || @user.companies.create(name: @user.name, creator: @user)
    @company.creator = @user if @company.creator.nil?
    @company.external_id = @company.creator.email
    @company.save
  end

  def attributes_for(model, row)
    case model
    when :user
      { email: @user.email, name: @user.name }
    when :company
      { name: @company.name, url: @company.url, email: @company.email, external_id: @company.external_id }
    else
      super(model, row)
    end
  end
end
