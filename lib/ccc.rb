module Ccc
  require 'active_support/dependencies/autoload'
  require 'active_support/core_ext'
  require 'market'

  MARKETS = ['bitflyer', 'zaif', 'korbit']

  def markets(markets = MARKETS)
    @markets ||= markets.each_with_object(Hash.new({})) do |market, h1|
      require "my_#{market}"
      h1[market] = "#{market.classify}::Currency".constantize.subclasses.each_with_object(Hash.new({})) do |currency, h2|
        h2[currency.to_s.split('::')[1].downcase] = "#{market.classify}::Action".constantize.new(currency.new)
      end
    end
  end

  def markets_with_currencies(markets = [])
    @markets_with_currencies ||= markets.each_with_object(Hash.new({})) do |market, h|
      require "my_#{market}"
      h[market] = "#{market.classify}::Currency".constantize.subclasses.map do |kls|
        kls.new
      end
    end
  end
  module_function :markets, :markets_with_currencies
end

