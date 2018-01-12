require 'ruby_coincheck_client'
require 'my_coincheck/currency'

# Module for Coincheck
module Coincheck
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