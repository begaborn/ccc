require 'json'
module Coincheck
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= CoincheckClient.new(
          api_key: conf[:api][:key],
          api_secret: conf[:api][:secret]
        )
      end

      def conf
        @conf ||= {
          api: {
            key: ENV['COINCHECK_API_KEY'], secret: ENV['COINCHECK_API_SECRET'],
          },
        }
      end
    end

    def currency_code
      super.upcase
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
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }