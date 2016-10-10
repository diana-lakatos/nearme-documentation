class DataSource::CustomSource < DataSource
  def parse!
    yield
  end
end
