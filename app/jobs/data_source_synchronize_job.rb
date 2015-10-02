class DataSourceSynchronizeJob < Job
  def after_initialize(data_source_id)
    @data_source_id = data_source_id
  end

  def perform
    @data_source = DataSource.find(@data_source_id)
    @data_source.parse!
  end
end
