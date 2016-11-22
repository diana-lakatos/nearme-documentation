class OrderSearchService
  def initialize(order_scope, options)
    @order_scope = order_scope
    @options = options
    @company_dashboard = options[:controller] == 'dashboard/company/orders_received'
    @all_states = Order.dashboard_tabs(@company_dashboard)
  end

  def state
    @state ||= (@all_states & [@options[:state]]).try(:first) || @all_states.first
  end

  def orders
    if state == 'archived'
      @orders = @order_scope.archived
    elsif state == 'not_archived'
      @orders = @order_scope.not_archived
    elsif state == 'draft'
      @orders = @order_scope.not_archived.where('state = ? AND draft_at IS NOT NULL', 'inactive')
    else
      @orders = @order_scope.not_archived.where(state: state)
    end

    if (order_types.values & (@options[:type] || [])).present?
      @orders = @orders.where(type: order_types.values & @options[:type])
    end

    if @options[:query] && @options[:query] =~ /[P|R|S]\d{8}/
      @orders = @orders.where(id: @options[:query][1..-1].to_i)
    elsif @options[:query].present?
      @orders = @orders.joins("INNER JOIN line_items ON line_items.line_itemable_id = orders.id AND line_items.line_itemable_type IN (\'#{Order::ORDER_TYPES.join('\',\'')}\') AND line_items.deleted_at IS NULL")
                .joins("INNER JOIN transactables ON line_items.line_item_source_id = transactables.id AND line_items.line_item_source_type = 'Transactable'")
                .where('transactables.name ILIKE(?)', "%#{ @options[:query].to_s }%")
    end

    @orders = @orders.paginate(per_page: 10, page: @options[:page])
              .order('starts_at ASC')
  end

  def order_types
    all_types = @order_scope.select(:type).group(:type).map(&:type)
    if all_types.size > 1
      {
        'Reservation' => 'Reservations',
        'RecurringBooking' => 'Subscription',
        'Purchase' => 'Orders' }
        .slice(*all_types).invert
    else
      {}
    end
  end

  def count(state)
    if instance_variable_defined?("@#{state}_count")
      instance_variable_get("@#{state}_count")
    else
      if state == 'archived'
        @orders = @order_scope.archived
      elsif state == 'not_archived'
        @orders = @order_scope.not_archived
      elsif state == 'draft'
        @orders = @order_scope.not_archived.where('state = ? AND draft_at IS NOT NULL', 'inactive')
      else
        @orders = @order_scope.not_archived.where(state: state)
      end

      instance_variable_set("@#{state}_count", @orders.count)
    end
  end

  def upcoming_count
    @upcoming_count ||= @order_scope.unconfirmed.count
  end

  def confirmed_count
    @confirmed_count ||= @order_scope.confirmed.not_archived.count
  end

  def archived_count
    @archived_count ||= @order_scope.archived.count
  end
end
