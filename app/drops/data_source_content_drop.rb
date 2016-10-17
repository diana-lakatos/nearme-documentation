class DataSourceContentDrop < BaseDrop
  # @!method id
  #   id of data_source_content as integer
  #   @return [Integer]
  # @!method json_content
  #   data for the object in JSON format
  #   @return (see DataSourceContent#json_content)
  # @!method content
  #   content for the object
  #   @return (see DataSourceContent#content)
  # @!method external_id
  #   external id for the object
  #   @return (see DataSourceContent#external_id)
  # @!method externally_created_at
  #   @return (see DataSourceContent#externally_created_at)
  delegate :id, :json_content, :content, :external_id, :externally_created_at, to: :source
end
