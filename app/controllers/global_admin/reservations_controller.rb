class GlobalAdmin::ReservationsController < GlobalAdmin::ResourceController

  def index
  end

  def show
    @periods =  ReservationPeriodDecorator.decorate_collection(resource.periods)
    show!
  end

  private

  def collection_allowed_scopes
    %w(upcoming past)
  end

  def collection_default_scope
    'upcoming'
  end

end

