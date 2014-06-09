module TransactableType::Payable
  extend ActiveSupport::Concern
  included do
    scope :filtered_by_price_types,  lambda { |price_types| where(price_types.map{|pt| "(properties->'#{pt}_price_cents') IS NOT NULL"}.join(' OR  ')) if price_types }
    attr_accessible :price_type

    # Number of minimum consecutive booking days required for this listing
    def minimum_booking_days
      if payable_for_one_day?
        1
      else
        if self.respond_to?(:monthly_price_cents) &&  monthly_price_cents.to_i > 0
          day_block_size_for_price(:monthly)
        else
          day_block_size_for_price(:weekly)
        end
      end
    end

    def day_block_size_for_price(price)
      price = price.to_sym
      return 0 if price
      return 1 if price == :daily
      multiple =  case price
                  when :weekly
                    1
                  when :monthly
                    4
                  else
                    1
                  end
      booking_days_per_week*multiple
    end

    # Returns a hash of booking block sizes to prices for that block size.
    def prices_by_days
      if self.respond_to?(:free?) && free?
        { 1 => 0.to_money }
      else
        pricing_options.inject({}) do |prices_by_days_array, price|
          prices_by_days_array[day_block_size_for_price(price)] = self.send("#{price}_price") if self.send("#{price}_price").to_i > 0
          prices_by_days_array
        end
      end
    end

    def has_price?
      return false unless is_payable?
      pricing_options.any? { |price| !self.send("#{price}_price_cents").to_f.zero? }
    end

    def price_type
      return nil unless is_payable?
      if self.respond_to?(:free?) && free?
        :free
      elsif self.respond_to?(:hourly_reservations?) && hourly_reservations?
        PRICE_TYPES[0] #Hourly
      elsif
        PRICE_TYPES[2] #Daily
      end
    end

    def price_type=(price_type)
      raise "Cannot set price type of transactable that is not payable" unless is_payable?
      case price_type.to_sym
      when PRICE_TYPES[2] #Daily
        self.free = false if self.respond_to?(:free)
        self.hourly_reservations = false if self.respond_to?(:hourly_reservations)
      when PRICE_TYPES[0] #Hourly
        self.free = false if self.respond_to?(:free)
        self.hourly_reservations = true
      when :free
        self.null_price!
        self.free = true
        self.hourly_reservations = false if self.respond_to?(:hourly_reservations)
      else
        errors.add(:price_type, 'no pricing type set')
      end
    end

    def null_price!
      raise "Cannot null prices for transactable that is not payable" unless is_payable?
      pricing_options.each { |price|
        self.send "#{price}_price_cents=", nil
      }
    end

    def lowest_price_with_type(available_price_types = [])
      return false unless is_payable?
      pricing_options.reject{ |price|
        !available_price_types.empty? && !available_price_types.include?(price.to_s)
      }.map { |price|
        [self.send("#{price}_price"), price]
      }.reject{|p| p[0].to_f.zero?}.sort{|a, b| a[0] <=> b[0]}.first
    end

    def is_payable?
      Hash === transactable_type.pricing_options
    end

    def pricing_options
      transactable_type.pricing_options.keys.reject { |k| k == "free" }
    end

    def payable_for_one_day?
      self.respond_to?(:free?) && free? ||
        self.respond_to?(:hourly_reservations?) && hourly_reservations? ||
        self.respond_to?(:daily_price_cents?) && daily_price_cents.to_i > 0 ||

        (daily_price_cents.to_i + weekly_price_cents.to_i + monthly_price_cents.to_i).zero?
    end

  end
end
