module Korbit
  # Currency Object.
  class Currency < Market::Currency
    class << self
      def client
        @client ||= Korbit::Client.new(
          client_id: conf[:api][:key],
          client_secret: conf[:api][:secret],
          username: conf[:api][:username],
          password: conf[:api][:password],
        )
      end

      def conf
        @conf ||= {
          api: {
            key: ENV['KORBIT_API_KEY'],
            secret: ENV['KORBIT_API_SECRET'],
            username: ENV['KORBIT_USERNAME'],
            password: ENV['KORBIT_PASSWORD'],
          },
        }
      end
    end

    def client
      self.class.client
    end

    def conf
      self.class.conf
    end

    def currency_code
      super.downcase
    end

    def pair
      'krw'
    end

    def currency_pair
      "#{currency_code}_#{pair}"
    end

    def balance
      @balacne ||= client.balance[currency_code]['available'].to_i
    end

    def krw
      balance * price
    end

    def krw_balance
      @krw_balance
    end

    def price
      @price ||= (ticker['last'].to_i || -1)
    end

    def volume
      binding.pry
      @volume ||= (detailed_ticker['volume'].to_i || -1)
    end

    def trades
      @trades ||= client.transactions.map do |trade|
        trade['date'] = (trade.delete('timestamp') / 1000).to_i
        trade
      end
    end

    def maker_fee
      user_volume[currency_pair]['maker_fee'].to_f
    end

    def taker_fee
      user_volume[currency_pair]['taker_fee'].to_f
    end

    def withdrawal_fee
      constants['btcWithdrawalFee'].to_f
    end

    def user_volume
      begin
        @user_volume ||= client.user_volume(currency_pair)
      rescue => e
        {}
      end

    end

    def transactions
      begin
        @transactions ||= client.transactions(currency_pair)
      rescue => e
        {}
      end
    end

    def detailed_ticker
      begin
        @detailed_ticker ||= client.detailed_ticker(currency_pair)
      rescue => e
        {}
      end
    end

    def ticker
      begin
        @ticker ||= client.ticker(currency_pair)
      rescue => e
        {}
      end
    end

    def constants
      begin
        @constants ||= client.constants
      rescue => e
        {}
      end
    end
  end
end
Dir[File.join(File.expand_path(File.dirname(__FILE__)), 'currency/*.rb')].each { |f| require f }