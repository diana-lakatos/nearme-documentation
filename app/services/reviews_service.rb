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
    completed_tab ? get_reviews_by(get_line_items_for_owner_and_creator) : get_reviewables(get_line_items_for_owner_and_creator)
  end

  def self.generate_csv_for(reviews)
    CSV.generate do |csv|
      csv.add_row %w(id rating user created_at)
      reviews.each do |review|
        csv.add_row review.attributes.values_at(*%w(id rating user_name created_at))
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
      transactable_type_id_per_subject: active_rating_systems.select { |rs| rs.transactable_type.is_a?(TransactableType) }.inject({}) { |hash, rs| hash[rs.subject] ||= []; hash[rs.subject] << rs.transactable_type_id; hash },
      active_rating_systems: active_rating_systems.group_by(&:transactable_type_id),
      buyer_rating_system: active_rating_systems.with_subject(RatingConstants::GUEST).group_by(&:transactable_type_id),
      seller_rating_system: active_rating_systems.with_subject(RatingConstants::HOST).group_by(&:transactable_type_id),
      product_rating_system: active_rating_systems.with_subject(RatingConstants::TRANSACTABLE).group_by(&:transactable_type_id)
    }
  end

  def get_reviews_by(reviewables)
    {
      seller_collection: Review.active_with_subject(RatingConstants::HOST).where(reviewable_id: reviewables[RatingConstants::HOST].to_a.map(&:id)).decorate,
      product_collection: Review.active_with_subject(RatingConstants::TRANSACTABLE).where(reviewable_id: reviewables[RatingConstants::TRANSACTABLE].to_a.map(&:id)).decorate,
      buyer_collection: Review.active_with_subject(RatingConstants::GUEST).where(reviewable_id: reviewables[RatingConstants::GUEST].to_a.map(&:id)).decorate
    }
  end

  def get_line_items_for_owner_and_creator
    if get_rating_systems[:transactable_type_id_per_subject].any?
      active_systems_for_host = get_rating_systems[:transactable_type_id_per_subject][RatingConstants::HOST]
      active_systems_for_guest = get_rating_systems[:transactable_type_id_per_subject][RatingConstants::GUEST]
      active_systems_for_listing = get_rating_systems[:transactable_type_id_per_subject][RatingConstants::TRANSACTABLE]

      host_line_item_scope = LineItem::Transactable.join_transactables.of_order_owner(@current_user)
                             .merge(Order.reviewable).where('transactables.creator_id != ?', @current_user.id)
      guest_line_item_scope = LineItem::Transactable.join_transactables.join_orders.of_lister(@current_user)
                              .where('transactables.transactable_type_id IN (?)', active_systems_for_guest).merge(Order.reviewable)
                              .where('orders.user_id != ?', @current_user.id)

      {
        RatingConstants::TRANSACTABLE => host_line_item_scope.where('transactables.transactable_type_id IN (?)', active_systems_for_listing).by_archived_at(*filter_period),
        RatingConstants::HOST => host_line_item_scope.where('transactables.transactable_type_id IN (?)', active_systems_for_host).by_archived_at(*filter_period),
        RatingConstants::GUEST => guest_line_item_scope.by_archived_at(*filter_period)
      }
    else
      {}
    end
  end

  def get_reviewables(reviewables)
    {
      seller_collection: exclude_reviewables_by(reviewables, RatingConstants::HOST).map(&:decorate),
      product_collection: exclude_reviewables_by(reviewables, RatingConstants::TRANSACTABLE).map(&:decorate),
      buyer_collection: exclude_reviewables_by(reviewables, RatingConstants::GUEST).map(&:decorate)
    }
  end

  def get_transactable_type_id
    if @params[:review][:reviewable_type].in? %w(Reservation LineItem::Transactable )
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
      date_range_array.map! { |string| Date.strptime(string, '%m/%d/%Y') }
      date_range *date_range_array
    end
  end

  def date_range(start_date, end_date = Time.zone.today)
    start_date.beginning_of_day..end_date.end_of_day
  end

  def exclude_reviewables_by(reservations, subject)
    if collection = reservations[subject]
      collection.where.not(id: reviewables_ids_with_feedback[key_for_constant(subject)])
    else
      []
    end
  end

  def reviewables_ids_with_feedback
    @reservation_ids_with_feedback ||= RatingConstants::RATING_SYSTEM_SUBJECTS.each_with_object({}) do |subject, hash|
      hash[key_for_constant(subject)] = Review.active_with_subject(subject).pluck(:reviewable_id)
    end
  end

  def key_for_constant(constant)
    :"#{constant}_ids"
  end
end
