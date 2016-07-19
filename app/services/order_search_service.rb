class OrderSearchService
  def initialize(order_scope, options)
    @order_scope = order_scope
    @options = options
  end

  def state
    @state ||= (Order.state_machine.states.map(&:name) + [:archived] & [@options[:state].try(:to_sym)]).try(:first) || :unconfirmed
  end

  def orders
    if @state == :archived
      @orders = @order_scope.archived
    else
      @orders = @order_scope.not_archived.where(state: @state)
    end

    if (@order_types.values & (@options[:type] || [])).present?
      @orders = @orders.where(type: @order_types.values & @options[:type])
    end

    if @options[:query] && @options[:query] =~ /[P|R|S]\d{8}/
      @orders = @orders.where(id: @options[:query][1..-1].to_i)
    elsif @options[:query]
      @orders = @orders.joins(:line_items).
        joins("INNER JOIN transactables ON line_items.line_item_source_id = transactables.id AND line_items.line_item_source_type = 'Transactable'").
        where('transactables.name ILIKE(?)', '%' + @options[:query].to_s + '%')

    end

    @orders = @orders.paginate(per_page: 10, page: @options[:page]).
      order('starts_at ASC')
  end

  def order_types
    all_types = @order_scope.select(:type).group(:type).map(&:type)
    @order_types = if all_types.size > 1
      {
        "Reservation" => "Reservations",
        "RecurringBooking" => "Subscription",
        "Purchase" => "Orders" }.
        slice(*all_types).invert
    else
      {}
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
