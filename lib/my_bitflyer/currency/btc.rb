require 'my_bitflyer'
module MyBitflyer
  class Btc < MyBitflyer::Currency
    def currency_code
      'BTC'
    end
  end
end 
