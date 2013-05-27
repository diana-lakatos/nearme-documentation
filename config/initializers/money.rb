# Set up the Money gem to use a default currency converter.
# By default, the Money gem converts currencies via conversion values
# assigned or loaded by an external API.
#
# Justification:
#
# At this stage, we never do currency 'conversions' so this functionality
# is irrelevant. Furthermore, when treating Money instances as scalar
# numeric values in the context of a comparison function (<, ==, >), this
# will inadvertently trigger a exchange rate conversion if the Money
# instance's currency is not the default currency (USD), since the scalar
# that the instance is being compared against will be converted to a
# Money instance of the default currency, and then converted to the target
# currency. In these situations, we are actually wanting to compare the
# fractional value of the currency itself. The simplest solution at this
# stage is to not trigger exchange rate conversions for Money instances
#  - i.e. treat the exchange rate as 1.
class NullConversionCurrencyBank < Money::Bank::Base
  # Implement an exchange method which doesn't trigger currency conversions,
  # just changes the Money value to use the other currency.
  def exchange_with(from, to_currency)
    Money.new(from.fractional, to_currency)
  end
end

Money.default_bank = NullConversionCurrencyBank.new

