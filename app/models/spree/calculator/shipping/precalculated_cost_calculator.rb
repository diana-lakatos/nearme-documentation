class Spree::Calculator::Shipping::PrecalculatedCostCalculator < Spree::ShippingCalculator
  def self.description
    "Precalculated cost calculator"
  end

  def compute_package(package)
    self.calculable.precalculated_cost
  end

end

