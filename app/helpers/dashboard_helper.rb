module DashboardHelper
  def dashboard_company_nav_class(company)
    classes = []

    if @location && @location.company == company
      classes << 'expanded'
    elsif @company && @company == company
      classes << 'active'
    end

    classes.join ' '
  end

  def dashboard_location_nav_class(location)
    classes = []

    if @location && @location == location
      classes << 'active'
    end

    classes.join ' '
  end
end
