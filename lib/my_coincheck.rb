require 'ruby_coincheck_client'
require 'my_coincheck/currency'

# Module for Coincheck
module Coincheck
  CURRENCIES = [:btc]

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
        require "my_coincheck/currency/#{currency}"
        define_method(currency) do
          new(Coincheck.send(currency))
        end
      end
    end
  end
end