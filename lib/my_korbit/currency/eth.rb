module Korbit
  class Eth < Currency
    def amount_digit
      8
    end

    def price_digit
      -2
    end
  end
end
