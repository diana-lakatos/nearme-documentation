class DataSourceContentDrop < BaseDrop

  # id
  #   id of data_source_content as integer
  # name
  #   name of data_source_content as string
  delegate :id, :json_content, :content, :external_id, :externally_created_at, to: :source

end

