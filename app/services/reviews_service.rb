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
    collections = {
      seller_collection: [],
      product_collection: [],
      buyer_collection: []
    }
    # the commented ifs will be removed and replaced with proper Order::LineItem
    #if PlatformContext.current.instance.buyable?
      line_items = get_line_items_for_owner_and_creator
      orders_reviews = completed_tab ? get_reviews_by(line_items) : get_reviewables(line_items, Spree::ProductType)
    #end
    #if PlatformContext.current.instance.bookable?
      reservations_for_owner_and_creator = get_reservations_for_owner_and_creator
      reservations_reviews = completed_tab ? get_reviews_by(reservations_for_owner_and_creator) : get_reviewables(reservations_for_owner_and_creator, ServiceType)
    #end
    #if PlatformContext.current.instance.biddable?
      offers_for_owner_and_creator = get_offers_for_owner_and_creator
      offer_reviews = completed_tab ? get_reviews_by(offers_for_owner_and_creator) : get_reviewables(offers_for_owner_and_creator, OfferType)
    #end
    collections.keys.each do |key|
      [orders_reviews, reservations_reviews, offer_reviews].compact.map do |reviews|
        collections[key] += reviews[key]
      end
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
    return @rating_system_hash if @rating_system_hash.present?
    active_rating_systems = RatingSystem.includes(:rating_hints, :rating_questions, :transactable_type).active
    @rating_system_hash ||= {
      active_rating_systems_services: active_rating_systems.select{ |rs| rs.transactable_type.is_a?(ServiceType) }.inject({}){ |hash, rs| hash[rs.subject] ||= []; hash[rs.subject] << rs.transactable_type_id; hash },
      active_rating_systems_products: active_rating_systems.select{ |rs| rs.transactable_type.is_a?(Spree::ProductType) }.inject({}){ |hash, rs| hash[rs.subject] ||= []; hash[rs.subject] << rs.transactable_type_id; hash },
      active_rating_systems_offers: active_rating_systems.select{ |rs| rs.transactable_type.is_a?(OfferType) }.inject({}){ |hash, rs| hash[rs.subject] ||= []; hash[rs.subject] << rs.transactable_type_id; hash },
      active_rating_systems: active_rating_systems.group_by { |rating_system| rating_system.transactable_type_id },
      buyer_rating_system: active_rating_systems.with_subject(RatingConstants::GUEST).group_by { |rating_system| rating_system.transactable_type_id },
      seller_rating_system: active_rating_systems.with_subject(RatingConstants::HOST).group_by { |rating_system| rating_system.transactable_type_id },
      product_rating_system: active_rating_systems.with_subject(RatingConstants::TRANSACTABLE).group_by { |rating_system| rating_system.transactable_type_id }
    }
  end

  def get_line_items_for_owner_and_creator
    active_systems_for_host = get_rating_systems[:active_rating_systems_products][RatingConstants::HOST]
    active_systems_for_guest = get_rating_systems[:active_rating_systems_products][RatingConstants::GUEST]
    active_systems_for_listing = get_rating_systems[:active_rating_systems_products][RatingConstants::TRANSACTABLE]
    orders_ids = @current_user.orders.reviewable.pluck(:id)
    creator_products = Spree::Product.where(administrator_id: @current_user.id, product_type_id: active_systems_for_host)
    creator_line_items_ids = []
    creator_products.each {|p| creator_line_items_ids << p.line_items.pluck(:id) }
    {
      RatingConstants::TRANSACTABLE => Spree::LineItem.where(order_id: orders_ids).joins(:product).where('spree_products.user_id != ?', @current_user.id).where(spree_products: { product_type_id: active_systems_for_listing}),
      RatingConstants::HOST => Spree::LineItem.where(order_id: orders_ids).joins(:product).where('spree_products.user_id != ?', @current_user.id).where(spree_products: { product_type_id: active_systems_for_host}),
      RatingConstants::GUEST => Spree::LineItem.where(id: creator_line_items_ids.uniq).joins(:product).joins(:order).where('spree_orders.user_id != ?', @current_user.id).where(spree_products: { product_type_id: active_systems_for_guest})
    }
  end

  def get_reviews_by(reviewables)
    {
      seller_collection: Review.active_with_subject(RatingConstants::HOST).where(reviewable: reviewables[RatingConstants::HOST].to_a).decorate,
      product_collection: Review.active_with_subject(RatingConstants::TRANSACTABLE).where(reviewable: reviewables[RatingConstants::TRANSACTABLE].to_a).decorate,
      buyer_collection: Review.active_with_subject(RatingConstants::GUEST).where(reviewable: reviewables[RatingConstants::GUEST].to_a).decorate
    }
  end

  def get_reservations_for_owner_and_creator
    if get_rating_systems[:active_rating_systems_services].any?
      active_systems_for_host = get_rating_systems[:active_rating_systems_services][RatingConstants::HOST]
      active_systems_for_guest = get_rating_systems[:active_rating_systems_services][RatingConstants::GUEST]
      active_systems_for_listing = get_rating_systems[:active_rating_systems_services][RatingConstants::TRANSACTABLE]
      reservations = Reservation.with_listing.reviewable.includes(listing: :transactable_type)
      {
        RatingConstants::TRANSACTABLE => reservations.where(owner_id: @current_user.id, transactables: {transactable_type_id: active_systems_for_listing}).where('reservations.owner_id != reservations.creator_id').by_period(*filter_period),
        RatingConstants::HOST => reservations.where(owner_id: @current_user.id, transactables: {transactable_type_id: active_systems_for_host}).where('reservations.owner_id != reservations.creator_id').by_period(*filter_period),
        RatingConstants::GUEST => reservations.where(creator_id: @current_user.id, transactables: {transactable_type_id: active_systems_for_guest}).where('reservations.owner_id != reservations.creator_id').by_period(*filter_period)
      }
    else
      {}
    end
  end

  def get_offers_for_owner_and_creator
    if get_rating_systems[:active_rating_systems_offers].any?
      active_systems_for_host = get_rating_systems[:active_rating_systems_offers][RatingConstants::HOST]
      active_systems_for_guest = get_rating_systems[:active_rating_systems_offers][RatingConstants::GUEST]
      active_systems_for_listing = get_rating_systems[:active_rating_systems_offers][RatingConstants::TRANSACTABLE]
      # TODO: Add rest states after accepted
      bids = Bid.with_state(:accepted).includes(offer: :offer_type)
      {
        RatingConstants::TRANSACTABLE => bids.where(user_id: @current_user.id,offers: { transactable_type_id: active_systems_for_listing }).where('bids.user_id != bids.offer_creator_id').by_period(*filter_period),
        RatingConstants::HOST => bids.where(user_id: @current_user.id, offers: { transactable_type_id: active_systems_for_host }).where('bids.user_id != bids.offer_creator_id').by_period(*filter_period),
        RatingConstants::GUEST => bids.where(offer_creator_id: @current_user.id, offers: { transactable_type_id: active_systems_for_guest }).where('bids.user_id != bids.offer_creator_id').by_period(*filter_period)
      }
    else
      {}
    end
  end



  def get_reviewables(reviewables, transactable_type)
    {
      seller_collection: exclude_reviewables_by(reviewables, RatingConstants::HOST, transactable_type).map(&:decorate),
      product_collection: exclude_reviewables_by(reviewables, RatingConstants::TRANSACTABLE, transactable_type).map(&:decorate),
      buyer_collection: exclude_reviewables_by(reviewables, RatingConstants::GUEST, transactable_type).map(&:decorate)
    }
  end

  def get_transactable_type_id
    if @params[:review][:reviewable_type].in? %w(Reservation Bid Spree::LineItem)
      @params[:review][:reviewable_type].constantize.find(@params[:review][:reviewable_id]).transactable_type_id
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

  def exclude_reviewables_by(reservations, subject, transactable_type)
    if collection = reservations[subject]
      collection.where.not(id: reviewables_ids_with_feedback(transactable_type)[key_for_constant(subject)])
    else
      []
    end
  end

  def reviewables_ids_with_feedback(tt_class)
    @reservation_ids_with_feedback = RatingConstants::RATING_SYSTEM_SUBJECTS.each_with_object({}) do |subject, hash|
      hash[key_for_constant(subject)] = Review.for_type_of_transactable_type(tt_class).active_with_subject(subject).pluck(:reviewable_id)
    end
  end


  def key_for_constant(constant)
    :"#{constant}_ids"
  end

end

