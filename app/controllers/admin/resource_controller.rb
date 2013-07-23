# An abstract controller class that provides common behaviour for basic
# CRUD for resources.
class Admin::ResourceController < Admin::BaseController
  inherit_resources

  protected

  def collection
    scope = end_of_association_chain

    if search = params[:search].presence
      conditions = collection_search_fields.map { |f| "#{f} ILIKE :s" }.join ' OR '
      escaped_search = ActiveRecord::Base.connection.quote_like_string(search)

      scope = scope.where(conditions, :s => "#{escaped_search}%")
    end

    scope.paginate(:page => params[:page])
  end

  # Fields that we can search on
  def collection_search_fields
    %w(name)
  end
end

