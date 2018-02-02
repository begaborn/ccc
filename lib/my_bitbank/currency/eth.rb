module Bitbank
  class Eth < Currency
    def initialize(pair = 'btc', market_conf = load_default_yml)
      @pair = pair
      @market_conf = market_conf[market_name] || {}
    end

    def price
      pair = Bitbank.send(@pair.to_sym)
      super * pair.price
    end
  end
end
