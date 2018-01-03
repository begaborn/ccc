module Zaif
  # Currency Object.
  class Currency < Market::Currency
    def client
      @client ||= Zaif::API.new(
        api_key: conf[:api][:key],
        api_secret: conf[:api][:secret]
      )
    end

    def currency_code
      super.downcase
    end

    def currency_pair
      "#{currency_code}_jpy"
    end

    def realtime_board(output_filename = nil)
      client.stream(currency_code, "jpy", output_filename)
    end

    def balance
      @balacne
    end

    def price
      @price ||= client.get_last_price(currency_code)
    end

    def trades
      client.get_trades(currency_code)
    end

    def ticker
      client.get_ticker(currency_code)
    end
    private

    def conf
      @conf ||= {
        api: {
          key: ENV['ZAIF_API_KEY'], secret: ENV['ZAIF_API_SECRET'],
        },
      }
    end
  end
end
