class Admin::DashboardController < Admin::BaseController

  def show
    @funnels = [Mixpanel::Presenter::Funnel.new('New Listings'), Mixpanel::Presenter::Funnel.new('Booking Flow')]
  end

end
