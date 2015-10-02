class DataSourceContentDrop < BaseDrop
  attr_reader :data_source_content

  # id
  #   id of data_source_content as integer
  # name
  #   name of data_source_content as string
  delegate :id, :content, :external_id, :externally_created_at, to: :data_source_content

  def initialize(data_source_content)
    @data_source_content = data_source_content
  end

end

