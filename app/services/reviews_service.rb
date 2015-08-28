class ReviewsService
  def initialize(current_user, params = {})
    @current_user = current_user
    @params = params
  end

  def get_reviews
    reviews = Review.joins(:user).select('reviews.*, users.name AS user_name')
    reviews = reviews.with_rating(@params[:rating]) if @params[:rating]
    reviews = reviews.with_date(date_from_params) if @params[:date].present?
    reviews = reviews.with_transactable_type(@params[:transactable_type]) if @params[:transactable_type]
    reviews
  end

  def get_reviews_collection(completed_tab)
    collections = {}
    if PlatformContext.current.instance.buyable?
      line_items = get_line_items_for_owner_and_creator
      orders_reviews = completed_tab ? get_orders_reviews(line_items) : get_orders(line_items)
    end
    if PlatformContext.current.instance.bookable?
      reservations_for_owner_and_creator = get_reservations_for_owner_and_creator
      reservations_reviews = completed_tab ? get_reviews_by(reservations_for_owner_and_creator) : get_reservations(reservations_for_owner_and_creator)
    end
    if orders_reviews && reservations_reviews
      orders_reviews.map{|k,v| collections[k] = reservations_reviews[k] + v }
    else
      collections = orders_reviews.presence || reservations_reviews.presence
    end
    collections
  end

  def self.generate_csv_for(reviews)
    CSV.generate do |csv|
      csv.add_row %w(id rating user created_at)
      reviews.each do |review|
        csv.add_row review.attributes.values_at(*%w{id rating user_name created_at})
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
      active_rating_systems: active_rating_systems.group_by { |rating_system| rating_system.transactable_type_id },
      buyer_rating_system: active_rating_systems.with_subject(RatingConstants::GUEST).group_by { |rating_system| rating_system.transactable_type_id },
      seller_rating_system: active_rating_systems.with_subject(RatingConstants::HOST).group_by { |rating_system| rating_system.transactable_type_id },
      product_rating_system: active_rating_systems.with_subject(RatingConstants::TRANSACTABLE).group_by { |rating_system| rating_system.transactable_type_id }
    }
  end

  def get_line_items_for_owner_and_creator
    orders_ids = @current_user.orders.reviewable.pluck(:id)
    creator_products = Spree::Product.where(administrator_id: @current_user.id)
    creator_line_items_ids = []
    creator_products.each {|p| creator_line_items_ids << p.line_items.pluck(:id) }
    {
      owner_line_items: Spree::LineItem.where(order_id: orders_ids).joins(:product).where('spree_products.user_id != ?', @current_user.id),
      creator_line_items: Spree::LineItem.where(id: creator_line_items_ids.uniq).joins(:order).where('spree_orders.user_id != ?', @current_user.id)
    }
  end

  def get_orders_reviews(line_items)
    {
      seller_collection: Review.active_with_subject(RatingConstants::HOST).by_line_items(line_items[:owner_line_items].pluck(:id)),
      product_collection: Review.active_with_subject(RatingConstants::TRANSACTABLE).by_line_items(line_items[:owner_line_items].pluck(:id)),
      buyer_collection: Review.active_with_subject(RatingConstants::GUEST).by_line_items(line_items[:creator_line_items].pluck(:id))
    }
  end

  def get_orders(line_items)
    {
      seller_collection: exclude_line_items_by(line_items, RatingConstants::HOST),
      product_collection: exclude_line_items_by(line_items, RatingConstants::TRANSACTABLE),
      buyer_collection: exclude_line_items_by(line_items, RatingConstants::GUEST)
    }
  end

  def get_reservations_for_owner_and_creator
    reservations = Reservation.with_listing.past.confirmed.includes(listing: :transactable_type)
    {
      owner_reservations: reservations.where(owner_id: @current_user.id).where('reservations.owner_id != reservations.creator_id').by_period(*filter_period),
      creator_reservations: reservations.where(creator_id: @current_user.id).where('reservations.owner_id != reservations.creator_id').by_period(*filter_period)
    }
  end

  def get_reviews_by(reservations)
    {
      seller_collection: Review.active_with_subject(RatingConstants::HOST).by_reservations(reservations[:owner_reservations].pluck(:id)),
      product_collection: Review.active_with_subject(RatingConstants::TRANSACTABLE).by_reservations(reservations[:owner_reservations].pluck(:id)),
      buyer_collection: Review.active_with_subject(RatingConstants::GUEST).by_reservations(reservations[:creator_reservations].pluck(:id))
    }
  end

  def get_reservations(reservations)
    {
      seller_collection: exclude_reservations_by(reservations, RatingConstants::HOST),
      product_collection: exclude_reservations_by(reservations, RatingConstants::TRANSACTABLE),
      buyer_collection: exclude_reservations_by(reservations, RatingConstants::GUEST)
    }
  end

  def get_transactable_type_id
    @params[:review][:reviewable_type] == 'Reservation' ? Reservation.find(@params[:review][:reviewable_id]).listing.transactable_type_id : Spree::LineItem.find(@params[:review][:reviewable_id]).product.product_type_id
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

  def exclude_reservations_by(reservations, subject)
    collection = subject == RatingConstants::GUEST ? reservations[:creator_reservations] : reservations[:owner_reservations]
    collection.where.not(id: reservation_ids_with_feedback[key_for_constant(subject)])
  end

  def exclude_line_items_by(line_items, subject)
    collection = subject == RatingConstants::GUEST ? line_items[:creator_line_items] : line_items[:owner_line_items]
    collection.where.not(id: line_items_ids_with_feedback[key_for_constant(subject)])
  end

  def reservation_ids_with_feedback
    @reservation_ids_with_feedback ||= RatingConstants::RATING_SYSTEM_SUBJECTS.each_with_object({}) do |subject, hash|
      hash[key_for_constant(subject)] = Review.for_type_of_transactable_type(ServiceType).active_with_subject(subject).pluck(:reviewable_id)
    end
  end

  def line_items_ids_with_feedback
    @line_items_ids_with_feedback ||= RatingConstants::RATING_SYSTEM_SUBJECTS.each_with_object({}) do |subject, hash|
      hash[key_for_constant(subject)] = Review.for_type_of_transactable_type(Spree::ProductType).active_with_subject(subject).pluck(:reviewable_id)
    end
  end


  def key_for_constant(constant)
    :"#{constant}_ids"
  end

end

