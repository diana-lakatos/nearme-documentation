class Listing::Search::Params::Web < Listing::Search::Params
  attr :location_string

  def bounding_box
    @bounding_box ||= [[@options[:nx], @options[:ny]], [@options[:sx], @options[:sy]]] if @options[:nx].present?
    super
  end

  def midpoint
    super
    @midpoint ||= [@options[:lat], @options[:lng]] if @options[:lat].present?
    @midpoint
  end

end
