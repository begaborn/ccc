module Zaif
  class Btc < Currency
    def amount_digit
      4
    end

    def price_digit
      -1
    end
  end
end
