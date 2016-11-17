# frozen_string_literal: true
class DataSourceContentDrop < BaseDrop
  # @!method id
  #   id of data_source_content as integer
  #   @return [Integer]
  # @!method json_content
  #   @return [String] data for the object in JSON format
  # @!method content
  #   @return [Hash] content for the object
  # @!method external_id
  #   @return [String] external id for the object
  # @!method externally_created_at
  #   @return (see DataSourceContent#externally_created_at)
  delegate :id, :json_content, :content, :external_id, :externally_created_at, to: :source
end
