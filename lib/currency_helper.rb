module CurrencyHelper
  def self.included(base)
    base.send(:module_function, :currencies)
    base::Currency.subclasses.each do |currency|
      currency_sym = currency.code.downcase.to_sym
      base.define_method(currency_sym) do
        currency.new
      end
      base.send(:module_function, currency_sym)
    end
  end

  # Currency code with symbolic
  # return [:btc, :bch, eth, ...]
  def currencies
    self::Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end
end

