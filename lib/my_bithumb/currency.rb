module Bithumb
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        Bithumb::Client.new(
          client_id: conf[:api][:key],
          client_secret: conf[:api][:secret],
        )
      end

      def conf
        {
          api: {
            key: ENV['BITHUMB_API_KEY'],
            secret: ENV['BITHUMB_API_SECRET'],
          },
        }
      end
    end


    def client
      @client ||= self.class.client
    end

    def conf
      @conf ||= self.class.conf
    end

    def currency_code
      super.upcase
    end

    def pair
      'krw'
    end

    def currency_pair
      "#{currency_code}_#{pair}"
    end

    def balance
    end

    def funds
    end

    def krw
    end

    def price
    end

    def volume
    end

    def trades
    end

    def maker_fee
    end

    def taker_fee
    end

    def withdrawal_fee
    end

    def unfilled_orders
    end

    def orderbook
      @orderbook ||= client.orderbook(currency_code)
    end

    def my_orders
    end

    def buy(price, amount, type = 'limit')
    end

    def sell(price, amount)
    end

    def cancel(tid)
    end

    def user_volume
    end

    def transactions
    end

    def ticker
        @ticker ||= client.ticker(currency_code)
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }