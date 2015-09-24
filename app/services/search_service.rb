class SearchService
  def initialize(scope)
    @scope = scope
  end

  def search(filtered_params = {})
    results = @scope
    filtered_params.each do |key, values|
      if values.present?
        results = results.public_send(key, *values)
      else
        results = results.public_send(key)
      end
    end
    results
  end
end
