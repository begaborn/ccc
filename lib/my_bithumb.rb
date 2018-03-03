require 'my_bithumb/bithumb'
require 'my_bithumb/currency'

# Module for Bithumb 
module Bithumb
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end
  module_function :currencies

  Currency.subclasses.each do |currency|
    currency_sym = currency.code.downcase.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end
end