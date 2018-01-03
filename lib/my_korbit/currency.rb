module Korbit
  # Currency Object.
  class Currency < Market::Currency
    def client
      @client ||= Korbit::Client.new(
        client_id: conf[:api][:key],
        client_secret: conf[:api][:secret],
        username: conf[:api][:username],
        password: conf[:api][:password]
      )
    end

    def currency_code
      super.downcase
    end

    def currency_pair
      "#{currency_code}_krw"
    end

    def balance
      @balacne
    end

    def krw_balance
      @krw_balance
    end

    def price
      @price ||= ticker['last']
    end

    def trades
      transactions
    end

    private

    def transactions(currency_pair)
      @transactions ||= client.transactions(currency_pair)
    end

    def detailed_ticker
      @detailed_ticker ||= client.detailed(currency_pair)
    end

    def ticker
      @ticker ||= client.ticker(currency_pair)
    end

    def constants
      @constants ||= client.constants
    end

    def conf
      @conf ||= {
        api: {
          key: ENV['KORBIT_API_KEY'],
          secret: ENV['KORBIT_API_SECRET'],
          username: ENV['KORBIT_USERNAME'],
          password: ENV['KORBIT_PASSWORD']
        },
      }
    end
  end
end
