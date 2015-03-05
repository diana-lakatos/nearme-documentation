class ReviewsService
  def initialize(current_user, current_instance, params = {})
    @current_user = current_user
    @current_instance = current_instance
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

  def get_rating_systems
    active_rating_systems = RatingSystem.includes(:rating_hints, :rating_questions).active
    {
      active_rating_systems: active_rating_systems,
      buyer_rating_system: active_rating_systems.find_by(subject:  @current_instance.lessee),
      seller_rating_system: active_rating_systems.find_by(subject:  @current_instance.lessor),
      product_rating_system: active_rating_systems.find_by(subject:  @current_instance.bookable_noun)
    }
  end

  def get_line_items_for_owner_and_creator
    orders_ids = @current_user.orders.complete.pluck(:id)
    creator_products = Spree::Product.where(administrator_id: @current_user.id)
    creator_line_items_ids = []
    creator_products.each{|p| creator_line_items_ids << p.line_items.pluck(:id) }
    {
      owner_line_items: Spree::LineItem.where(order_id: orders_ids),
      creator_line_items: Spree::LineItem.where(id: creator_line_items_ids.uniq)
    }
  end

  def get_orders_reviews(line_items)
    {
      seller_collection: reviews_with_object('seller').by_line_items(line_items[:owner_line_items].pluck(:id)),
      product_collection: reviews_with_object('product').by_line_items(line_items[:owner_line_items].pluck(:id)),
      buyer_collection: reviews_with_object('buyer').by_line_items(line_items[:creator_line_items].pluck(:id))
    }
  end

  def get_orders(line_items)
    {
      seller_collection: exclude_line_items_by(line_items, :seller_ids),
      product_collection: exclude_line_items_by(line_items, :product_ids),
      buyer_collection: exclude_line_items_by(line_items, :buyer_ids)
    }
  end

  def get_reservations_for_owner_and_creator
    reservations = Reservation.with_listing.past.confirmed.includes(listing: :transactable_type)
    {
      owner_reservations: reservations.where(owner_id: @current_user.id).by_period(*filter_period),
      creator_reservations: reservations.where(creator_id: @current_user.id).by_period(*filter_period)
    }
  end

  def get_reviews_by(reservations)
    {
      seller_collection: reviews_with_object('seller').by_reservations(reservations[:owner_reservations].pluck(:id)),
      product_collection: reviews_with_object('product').by_reservations(reservations[:owner_reservations].pluck(:id)),
      buyer_collection: reviews_with_object('buyer').by_reservations(reservations[:creator_reservations].pluck(:id))
    }
  end

  def get_reservations(reservations)
    {
      seller_collection: exclude_reservations_by(reservations, :seller_ids),
      product_collection: exclude_reservations_by(reservations, :product_ids),
      buyer_collection: exclude_reservations_by(reservations, :buyer_ids)
    }
  end

  def get_transactable_type_id
    @params[:review][:reviewable_type] == 'Reservation' ? Reservation.find(@params[:review][:reviewable_id]).listing.transactable_type_id : @current_instance.buyable_transactable_type.id
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

  def exclude_reservations_by(reservations, type)
    collection = type == :buyer_ids ? reservations[:creator_reservations] : reservations[:owner_reservations]
    collection.where.not(id: reservation_ids_with_feedback[type])
  end

  def exclude_line_items_by(line_items, type)
    collection = type == :buyer_ids ? line_items[:creator_line_items] : line_items[:owner_line_items]
    collection.where.not(id: line_items_ids_with_feedback[type])
  end

  def reservation_ids_with_feedback
    @reservation_ids_with_feedback ||= RatingConstants::FEEDBACK_TYPES.each_with_object({}) do |type, hash|
      hash["#{type}_ids".to_sym] = reviews_with_object(type).pluck(:reviewable_id)
    end
  end

  def line_items_ids_with_feedback
    @line_items_ids_with_feedback ||= RatingConstants::FEEDBACK_TYPES.each_with_object({}) do |type, hash|
      hash["#{type}_ids".to_sym] = reviews_with_object(type).pluck(:reviewable_id)
    end
  end

  def reviews_with_object(type)
    @current_user.reviews.with_object(type)
  end
end
