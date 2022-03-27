require "ccc/version"
require "ccc/configuration"
require 'currency_helper'
require 'active_support/dependencies/autoload'
require 'active_support/core_ext'
require 'market'

Dir.glob('**/*rb', File::FNM_DOTMATCH, base: File.dirname(__FILE__)).each do |file|
  require file
end

module Ccc
  def configure
    yield configuration
  end

  def configuration
    @configuration ||= Ccc::Configuration.new
  end
  module_function :configure, :configuration

  MARKETS = ['zaif', 'korbit', 'bitbank']

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

