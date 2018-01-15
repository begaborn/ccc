module Zaif
  class Bch < Currency
    def currency_code
      super.upcase
    end
  end
end
