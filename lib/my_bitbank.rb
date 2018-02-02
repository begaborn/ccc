require 'ruby_bitbankcc'
require 'my_bitbank/currency'

# Module for Bitbank
module Bitbank
  # Currency code with symbolic
  # return [:btc, :bch, eth, ...]
  def currencies
    Currency.subclasses.map do |currency|
      currency_sym = currency.code.downcase.to_sym
    end
  end

  module_function :currencies

  # Define method that get the currency object
  # Usage: btc = Bitbank.btc
  Currency.subclasses.each do |currency|
    currency_sym = currency.code.downcase.to_sym
    define_method(currency_sym) do
      currency.new
    end
    module_function currency_sym
  end
end
