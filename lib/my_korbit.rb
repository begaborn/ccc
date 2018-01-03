require 'korbit'
require 'my_korbit/currency'

# Module for Korbit
module Korbit
  CURRENCIES = [:btc, :bch, :eth, :btg, :xrp]

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
        require "my_korbit/currency/#{currency}"
        define_method(currency) do
          new(Korbit.send(currency))
        end
      end
    end
  end
end