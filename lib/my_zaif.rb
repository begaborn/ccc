require 'zaif'
require 'my_zaif/currency'

# Module for Zaif
module Zaif
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

  # Action Class decide action for Selling, Buying, etc
  class Action < Market::Action
    class << self
      Currency.subclasses.each do |currency|
        currency_sym = currency.to_s.split('::')[1].downcase.to_sym
        define_method(currency_sym) do
          new(Zaif.send(currency_sym))
        end
      end
    end
  end
end