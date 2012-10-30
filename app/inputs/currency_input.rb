class CurrencyInput < SimpleForm::Inputs::GroupedCollectionSelectInput
  COMMON_CODES = ['USD', 'EUR', 'NZD', 'AUD', 'GBP']

  def grouped_collection
    common = currencies.select { |c| COMMON_CODES.include? c[:iso_code] }
    [prep_currencies('Common', common), prep_currencies('All', currencies)]
  end

  def group_method
    :currencies
  end

  def group_label_method
    :name
  end


  def prep_currencies(name, currencies)
    CurrencyGroup.new(name, currencies.collect do |c|
      Currency.new(c[:iso_code], c[:name])
    end)
  end

  def currencies
    @currencies ||= Money::Currency.table.values.sort_by { |c| c[:iso_code] }
  end

  class CurrencyGroup < Struct.new(:name, :currencies)
    def include?(name)
      currencies.any? { |c| c.name == name }
    end
  end

  class Currency < Struct.new(:iso_code, :aname)
    def name
      "#{iso_code} - #{aname}"
    end

    def to_s
      iso_code
    end

  end
end
