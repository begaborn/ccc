module Zaif
  class Eth < Currency
    def currency_code
      super.upcase
    end
  end
end
