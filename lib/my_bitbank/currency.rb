module Bitbank
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= bbcc = Bitbankcc.new(
          conf[:api][:key],
          conf[:api][:secret]
        )
      end

      def conf
        @conf ||= {
          api: {
            key: ENV['BITBANK_API_KEY'], secret: ENV['BITBANK_API_SECRET'],
          },
        }
      end
    end

    def currency_code
      super.downcase
    end

    def price
      ticker['data']['last'].to_f
    end

    def volume
      ticker['data']['vol'].to_f
    end

    def trades
      JSON.parse(client.read_transactions(currency_pair).body)
    end

    def ticker
      JSON.parse(client.read_ticker(currency_pair).body)
    end

    def my_trade
      JSON.parse(client.read_trade_history(currency_pair))
    end

    def balance
      JSON.parse(client.read_balance)
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }