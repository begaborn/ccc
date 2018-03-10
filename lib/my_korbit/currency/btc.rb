module Korbit
  class Btc < Currency
    def amount_digit
      8
    end

    def price_digit
      -2
    end
  end
end
