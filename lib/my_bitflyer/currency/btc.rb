require 'my_bitflyer/currency'
module Bitflyer
  def btc
    self::Btc.new
  end
  module_function :btc

  class Btc < Bitflyer::Currency
    def currency_code
      'BTC'
    end
  end
end
