module Zaif
  class Eth < Currency
    def currency_code
      super.upcase
    end

    def amount_digit
      4
    end

    def price_digit
      -1
    end
  end
end
