module Bitbank
  class Eth < Currency
    def default_pair
      'btc'
    end

    def price
      pair = Bitbank.send(self.pair.to_sym)
      super * pair.price
    end
  end
end
