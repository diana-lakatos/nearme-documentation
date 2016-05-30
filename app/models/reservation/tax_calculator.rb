class Reservation::TaxCalculator
  attr_reader :reservation

  def initialize(reservation)
    @reservation = reservation
    @listing = @reservation.listing
    @seller_company = @listing.company
    @buyer_address = @reservation.owner.try(:current_address)
    @seller_address = @reservation.host.try(:current_address) || @seller_company.try(:company_address)
  end

  def included_tax_amount_cents
    (0.01 * included_tax_rate.value * @reservation.total_amount_cents) / (1 + 0.01 * included_tax_rate.value)
  end

  def tax_rates
    tax_region = TaxRegion.find_by_country_id(@seller_address.country_object.try(:id))
    @tax_rates ||= TaxRate.where(state: [@seller_address.state_object, nil], tax_region: tax_region)
  end

  def included_tax_rate
    tax_rate(included_in_price: true)
  end

  def additional_tax_rate
    tax_rate(included_in_price: false)
  end

  def build_additional_tax_rate
    return nil if additional_tax_rate.blank? || additional_tax_rate.value.zero?

    @reservation.additional_charges.build(
      target: @reservation,
      currency: @reservation.currency,
      name: additional_tax_rate.name,
      commission_receiver: 'host',
      amount_cents: 0.01 * additional_tax_rate.value * @reservation.total_amount_cents)
  end

  def tax_rate(options)
    return OpenStruct.new(name: 'Tax', value: 0) unless valid?

    case (included_rates = tax_rates.where(options)).count
    when 0 then nil
    when 1 then included_rates.first
    else
      if included_rates.where(calculate_with: :replace).any?
        included_rates.where(calculate_with: :replace).first
      else
        OpenStruct.new(name: included_rates.default.first.name, value: included_rates.sum(:value))
      end
    end || OpenStruct.new(name: 'Tax', value: 0)
  end

  def valid?
    @seller_address.present? && @seller_company.present? && @listing.present? && @reservation.present?
  end
end
