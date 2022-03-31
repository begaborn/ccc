module Bybit
  class Btc < Currency
    def price_digit
      2
    end

    def amount_digit
      6
    end
  end
end
