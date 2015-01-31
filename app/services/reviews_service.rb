class ReviewsService
  def initialize(params = {})
    @params = params
  end

  def get_reviews
    reviews = Review.joins(:user).select('reviews.*, users.name AS user_name')
    reviews = reviews.with_rating(@params[:rating]) if @params[:rating]
    reviews = reviews.with_date(date_from_params) if @params[:date].present?
    reviews = reviews.with_transactable_type(@params[:transactable_type]) if @params[:transactable_type]
    reviews
  end

  def generate_csv_for(reviews)
    CSV.generate do |csv|
      csv.add_row %w(id object rating user created_at)
      reviews.each do |review|
        csv.add_row review.attributes.values_at(*%w{id object rating user_name created_at})
      end
    end
  end

  def filter_period
    if @params[:period].blank? || @params[:period] == Review::LAST_30_DAYS
      30.days.ago.to_date
    elsif @params[:period] == Review::LAST_6_MONTHS
      6.months.ago.to_date
    else
      year = @params[:period].to_i
      [DateTime.new(year).to_date, DateTime.new(year).end_of_year.to_date] 
    end
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