# An abstract controller class that provides common behaviour for basic
# CRUD for resources.
class GlobalAdmin::ResourceController < GlobalAdmin::BaseController
  inherit_resources

  protected

  def collection
    scope = end_of_association_chain

    # Filter by search param
    if search = params[:search].presence
      conditions = collection_search_fields.map { |f| "#{f} ILIKE :s" }.join ' OR '
      escaped_search = ActiveRecord::Base.connection.quote_like_string(search)

      scope = scope.where(conditions, s: "#{escaped_search}%")
    end

    # Filter scopes
    list_scope = params[:scope].presence
    if collection_allowed_scopes.include?(list_scope)
      scope = scope.send(list_scope)
    elsif collection_default_scope
      scope = scope.send(collection_default_scope)
    end

    # Order the collection by created_at descending
    scope = scope.order('created_at DESC')

    # Paginate the collection
    scope.paginate(page: params[:page])
  end

  # Fields that we can search on
  def collection_search_fields
    %w(name)
  end

  # Allowed scopes to filter a collection by
  def collection_allowed_scopes
    %w()
  end

  # Default scope to filter a collection by
  def collection_default_scope
  end
end
