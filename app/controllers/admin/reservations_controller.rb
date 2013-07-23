class Admin::ReservationsController < Admin::ResourceController

  def index
  end

  private

  def collection_allowed_scopes
    %w(upcoming past)
  end

  def collection_default_scope
    'upcoming'
  end

end

