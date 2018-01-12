require 'bitflyer'
require 'my_bitflyer/currency'

# Module for Bitflyer
module Bitflyer
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.to_sym
    end
  end
  module_function :currencies

  Currency.subclasses.each do |currency|
    currency_sym = currency.code.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end
end
