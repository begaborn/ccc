require 'binance'
require 'my_binance/currency'

module Binance
  def currencies
    @currencies ||= Binance::Client::REST.new.exchange_info['symbols'].map do |sym|
      sym['baseAsset'].downcase.to_sym if sym['baseAsset'][0]&.match? /[[:upper:]]/
    end.uniq.compact
  end
  module_function :currencies

  currencies.each do |currency_sym|
    kls = Class.new(Binance::Currency)
    Binance::Currency.const_set(currency_sym.to_s.classify, kls)
    define_method(currency_sym) { kls.new }
    module_function currency_sym
  end
end
