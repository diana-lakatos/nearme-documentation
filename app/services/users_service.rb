class UsersService
  def initialize(platform_context, params = {})
    @platform_context = platform_context
    @params = params
  end

  def get_users
    users = User.for_instance(@platform_context.instance)
    users = users.order("created_at DESC")
    users = users.where("name ilike ? or email ilike ?", "%#{@params[:q]}%", "%#{@params[:q]}%") if @params[:q].present?
    users = users.with_date(date_from_params) if @params[:date].present?
    users = users.is_guest if @params[:filters].try(:include?, 'guest')
    users = users.is_host if @params[:filters].try(:include?, 'host')
    users
  end

  private

  def date_from_params
    case @params[:date]
    when 'today' then date_range Time.zone.today
    when 'yesterday' then date_range(Time.zone.today.yesterday, Time.zone.today.yesterday)
    when 'week_ago' then date_range 1.week.ago.to_date
    when 'month_ago' then date_range 1.month.ago.to_date
    when '3_months_ago' then date_range 3.months.ago.to_date
    when '6_months_ago' then date_range 6.months.ago.to_date
    else
      date_range_array = @params[:date].split('-')
      date_range_array.map! {|string| Date.strptime(string, '%m/%d/%Y') }
      date_range *date_range_array
    end
  end

  def date_range(start_date, end_date = Time.zone.today)
    start_date.beginning_of_day..end_date.end_of_day
  end
end
