require 'zaif'
require 'my_zaif/currency'

# Module for Zaif
module Zaif
  CURRENCIES = [:btc, :mona, :xem, :bch, :eth]

  CURRENCIES.each do |currency|
    define_method(currency) do
      "#{self.to_s}::#{currency.to_s.classify}".constantize.new
    end
    module_function currency
  end

  # Action Class decide action for Selling, Buying, etc
  class Action < Market::Action
    class << self
      CURRENCIES.each do |currency|
        require "my_zaif/currency/#{currency}"
        define_method(currency) do
          new(Zaif.send(currency))
        end
      end
    end
  end
end