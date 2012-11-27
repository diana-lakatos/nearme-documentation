module DashboardHelper
  def dashboard_company_nav_class(company)
    classes = []

    if @company && @company == company
      classes << 'expanded'
      classes << 'active'
    elsif @location && @location.company == company
      classes << 'expanded'
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
