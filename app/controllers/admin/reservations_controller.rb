class Admin::ReservationsController < Admin::ResourceController
  before_filter :filter_scope

  def index
  end

  private

  def filter_scope
    unless %w(upcoming past).include?(params[:scope])
      params[:scope] = 'upcoming'
    end
  end

  def collection
    case params[:scope]
    when 'upcoming'
      super.upcoming
    when 'past'
      super.past
    end
  end
end

