module Binance
  class Currency < Market::Currency
    def currency_code
      super.upcase
    end
  end
end
