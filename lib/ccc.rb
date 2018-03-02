require "ccc/version"
require "ccc/configuration"
require 'active_support/dependencies/autoload'
require 'active_support/core_ext'
require 'market'
require 'my_zaif'
require 'my_coincheck'
require 'my_bitflyer'
require 'my_korbit'
require 'my_bitbank'
require 'my_bithumb'

module Ccc
  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Ccc::Configuration.new
  end
  module_function :configure, :configuration

  MARKETS = ['bitflyer', 'zaif', 'korbit', 'bitbank', 'bithumb']

  def currency(market, currency_code)
    require "my_#{market}"
    market.classify.constantize.send(currency_code.downcase.to_sym)
  end

  def markets(markets = MARKETS)
    @markets ||= markets.each_with_object(Hash.new({})) do |market, h1|
      require "my_#{market}"
      h1[market] = "#{market.classify}::Currency".constantize.subclasses.each_with_object(Hash.new({})) do |currency, h2|
        h2[currency.code.downcase.to_sym] = "#{market.classify}".constantize.send(currency.code.downcase.to_sym)
      end
    end
  end

  module_function :currency, :markets
end

