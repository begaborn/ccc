require 'json'
module Coincheck
  # Currency Object.
  class Currency < Market::Currency
    def client
      @client ||= CoincheckClient.new(
        api_key: conf[:api][:key],
        api_secret: conf[:api][:secret]
      )
    end

    def currency_code
      super.upcase
    end

    def balance
      @balacne
    end

    def price
      @price ||= rate['rate'].to_f
    end

    def rate
      JSON.parse(client.read_rate.body)
    end

    def order_books
      @order_books ||= JSON.parse(client.read_order_books.body)
    end

    def trades
      @ticker ||= JSON.parse(client.read_trades.body)
    end

    def ticker
      @ticker ||= JSON.parse(client.read_ticker.body)
    end

    private

    def conf
      @conf ||= {
        api: {
          key: ENV['COINCHECK_API_KEY'], secret: ENV['COINCHECK_API_SECRET'],
        },
      }
    end
  end
end
