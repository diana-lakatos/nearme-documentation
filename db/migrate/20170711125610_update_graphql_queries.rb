class UpdateGraphqlQueries < ActiveRecord::Migration
  def change
    GraphQuery.find_each do |q|
      q.update_attributes! query_string: fixed_query_string(q.query_string)
    end
  end

  private

  def fixed_query_string(string)
    string
      .gsub('custom_attributes:', 'properties:')
      .gsub('custom_attribute(name:', 'property(name:')
      .gsub('custom_attribute_array', 'property_array')
  end
end
